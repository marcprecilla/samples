class UsersController < ApplicationController
  skip_before_filter :require_ssl, only: [:terms, :privacy, :unsubscribe]
  skip_before_filter :authenticate, only: [:new, :create, :terms, :privacy, :unsubscribe, :new_password_reset_token, :create_password_reset_token, :edit_password, :update_password]
  skip_before_filter :accept_terms, only: [:terms, :privacy, :unsubscribe, :update]
  skip_before_filter :verify_subscription
  skip_before_filter :complete_onboarding

  def new
    @user = User.new
    @name = params[:name]
    @email = params[:email]
    @password = @password_confirmation = nil
  end

  def create
    @return_path ||= params[:return_path]

    @name = params[:name]
    @first_name = params[:first_name]
    @last_name = params[:last_name]

    if params[:user]
      @user = User.new(user_params)
      @email = @user.email
    else
      @user = User.new
      @user.name = @name if @name
      @user.first_name = @first_name if @first_name
      @user.last_name = @last_name if @last_name
      @user.email = @email = params[:email]
      @user.password = @password = params[:password]
      @user.password_confirmation = @password_confirmation = params[:password_confirmation]
    end

    lead = Lead.find_by_email(params[:email])
    @user.source = lead.try(:source) || session[:source]
    @user.campaign = lead.try(:campaign) || session[:campaign]
    @user.landing_page = lead.try(:landing_page) ||session[:landing_page]
    @user.original_url = lead.try(:original_url)

    copy_lead_info_to_user(@user)

    @user.save!
    login_as @user

    Resque.enqueue(UpdateMailChimp, @email, :user)

    begin
      # update subscription
      current_user.apply_coupon!(current_coupon.id) if current_coupon
      current_user.set_offer_and_subscription_plan!(current_offer, current_plan) if current_offer && current_plan
      Rails.logger.info "Subscription updated."
    rescue Stripe::StripeError => e
      log "StripeError: #{e.message}"
      # ignore StripeErrors here
    end

    # show walkthroughs for first session
    session[:show_dashboard_walkthrough] = true
    session[:show_action_plan_walkthrough] = true
    session[:show_progress_walkthrough] = true

    flash.notice = 'Registration succeeded.'

    log "return path=(#{@return_path})"

    case @return_path
    when new_subscription_path
        log "NAV: The request has the new_subscription_path set as the return path..."

      if current_user.stripe_subscription_active?
        clear_subscription_data

        log "NAV ...and there is an active subscription, clearing the session data associated with the selected subscription and redirecting to subscription_confirm_path: #{subscription_confirm_path}"
        redirect_to subscription_confirm_path
      else
        log "NAV ...so I'm redirecting to new_subscription_path: #{new_subscription_path}"
        redirect_to new_subscription_path
      end
    else
      # if an assessment is associated with the email and the assessment hasn't just been created, then nav to the assessment results
      if lead && lead.assessment

        if lead.assessment.created_at > 30.minutes.ago # i.e. created "recently"
          log "NAV: There is an assessment that was created less than 30 minutes ago, so the user will have seen the results already... so I am bypassing and going to the free dashboard (which is the root path)"
          redirect_to root_path
        else
          log "NAV: older assessment... sent the visitor to the results"
          redirect_to assessment_path(lead.assessment)
        end
      else
        if @user.facebook_identifier
          log "NAV: I see that this is a facebook user (#{@user.facebook_identifier})"

          if session[:lead_info] && session[:lead_info][:assessment_uuid] &&
             assessment = Assessment.find_by_uuid(session[:lead_info][:assessment_uuid])

            log "I've found an assessment associated with this facebook user (#{assessment.uuid}), so I'm emailing the assessment results to the user and redirecting to the assessment results"

            Resque.enqueue(SendAssessmentResultsEmail, assessment.uuid, @user.first_name, @user.email, session)

            # .. and show the assessment
            redirect_to assessment_path(assessment)
          else
            log "NAV Since I haven't found an assessment for this facebook user, I'm sending her to the new assessment path (#{mini_baseline_path})"
            redirect_to mini_baseline_path
          end # if assessment found
        else # not a facebook user
          log "NAV: I see that this is NOT a facebook user, I'm going to send to the root path "
          redirect_to root_path
        end 
      end
    end

    mixpanel_track 'Created User', {facebook: !@user.facebook_identifier.nil?}
    mixpanel_alias @user.uuid
    log "Completed user/create"

  rescue => e
    user_errors = @user.errors.full_messages.join(', ') if @user
    log "#{e.message}: #{user_errors}"

    # render instead of redirect to maintain instance variables
    case @return_path
    when new_subscription_path
      @selected_tab = 'registration-tab'
      render 'subscriptions/new'
    else
      render 'new'
    end

  end

  def edit
    @user = current_user

    # if @user.receive_email_notifications.nil?
    #   @show_intro = @user.receive_email_notifications = true
    # end

    @photo_upload_enabled = true;
    if browser.iphone? || browser.ipad? || browser.ipod?
      if request.env['HTTP_USER_AGENT'].downcase.match(/os 5/)
        @photo_upload_enabled = false;
      end
    end

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax", :action => 'onboarding'
    else
      render 'onboarding'
    end

  end

  # this call completes onboarding
  def update
    @enrollment = current_enrollment
    @user = @enrollment.user

    if params[:image_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:image_id])
      if preloaded.valid?
        params[:user][:profile_image_url] = Cloudinary::Utils.cloudinary_url(preloaded.identifier, { angle: 'exif' })
      end
    end

    copy_lead_info_to_user(@user)

    mixpanel_track('Alerts Turned Off',{}) if params[:user][:receive_email_notifications] == "0" &&   @user.receive_email_notifications?
    mixpanel_track('Alerts Turned On',{})  if params[:user][:receive_email_notifications] == "1" && ! @user.receive_email_notifications?

    saved = @user.update_attributes(params[:user])

    flash.notice = "User updated." if saved
    Rails.logger.debug "Errors: #{@user.errors.full_messages}" if @user.errors.any?

    case params[:flow]
    when 'notifications'
      if saved
        redirect_to settings_path
      else
        render 'settings_notifications'
      end
    when 'subscription-confirmation'
      if saved
        redirect_to terms_path
      else
        render 'subscriptions/confirm'
      end
    when 'update-avatar'
      redirect_to "/action_plan?skip_intro=1"
    else
      if params[:show_desktop].present?
        redirect_to new_invite_path + '?invitesrc=emailinvite&show_desktop=1'
      else
        redirect_to new_invite_path + '?invitesrc=emailinvite'
      end
    end

    # respond_to do |format|
    #   format.html {redirect_to new_invite_path + '?invitesrc=emailinvite'}
    #   format.js {render nothing: true}
    # end
  end

  def update_password
    # todo
  end

  def terms

    #after purchase
    #for google/optimizely tracking js
    @purchase_information = session.delete(:purchase_information)

    if request.post? && params[:accepted]
      # accept terms
      current_user.update_attribute(:terms_accepted_on, Time.now)

      # send welcome message
      Resque.enqueue(SendWelcomeEmail, current_user.name, current_user.email) unless current_user.email.blank?
      Resque.enqueue(SendWelcomeSms, current_user.uuid) unless current_user.mobile_phone.blank?

      # show the bookmark page if ios device
      if browser.iphone? || browser.ipad? || browser.ipod?
        session[:show_bookmark_page] = true
      end

      # continue
      redirect_to root_path
    else
      render 'terms'
    end
  end

  def privacy
    render 'privacy'
  end

  def settings
    @user = current_user
    @menu_section = 'settings'

    case params[:flow]
      when 'notifications'
        if desktop?
          render :layout => "layouts/application_desktop", :action => "settings_notifications"
        else
          render 'settings_notifications'
        end
      when 'subscription'
        if @subscription = current_user.current_stripe_subscription
          @status = @subscription.status
          @canceling = @subscription.cancel_at_period_end
          @trial_end = Time.at(@subscription.trial_end).to_date.to_formatted_s(:long_ordinal) if @subscription.trial_end
          @period_end = Time.at(@subscription.current_period_end).to_date.to_formatted_s(:long_ordinal) if @subscription.current_period_end
          @plan = @subscription.plan
        end

        if params[:show_desktop].present?
          render :layout => "layouts/application_ajax", :action => "settings_subscription"
        else
          render "settings_subscription"
        end
      else
        if desktop?
          render :layout => "layouts/application_desktop", :action => "settings"
        else
          render 'settings'
        end
    end


  end

  def unsubscribe
    @user = User.where(email: CGI.unescape(params[:email])).first if params[:email]
    @user.update_attribute(:receive_email_notifications, false) if @user
  end

  ######################################################################
  # passwords
  ######################################################################

  NO_EMAIL = 'No email address supplied.'
  USER_NOT_FOUND = 'A user with that email address could not be found.'
  TOKEN_MISSING = 'Password reset token is missing or invalid. Please request one below.'
  TOKEN_INVALID = 'Password reset token has expired. Please request a new one below.'

  def new_password_reset_token
    @email = params[:email]

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax", :action => 'request_password_token'
    else
      render 'request_password_token'
    end

  end

  def create_password_reset_token
    @email = params[:email]

    raise NO_EMAIL if @email.blank?
    raise USER_NOT_FOUND unless @user = User.where(email: @email).first

    # generate a new password reset token, unless one was created within the last hour
    @user.generate_password_reset_token! unless @user.password_reset_token && @user.password_reset_generated_at > 1.hour.ago

    m = Mandrill::API.new
    message = {
      subject: 'Password Reset Instructions',
      from_name: 'App Support',
      from_email: 'support@myApp.com',
      to: [email: @user.email, name: @user.name],
      html: render_to_string(file: 'app/views/mandrill/password_reset_instructions', layout: false),
      track_opens: false,
      track_clicks: false
    }
    m.messages.send message

    flash.notice = 'Please check your email for instructions on resetting your password.'

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax", :action => 'request_password_success'
    else
      render 'request_password_success'
    end

  rescue => e
    flash.alert = e.message

    redirect_to new_password_path(email: @email)
  end

  def edit_password
    @token = params[:password_reset_token]
    raise TOKEN_MISSING if @token.blank?

    @user = User.where(password_reset_token: @token).first
    raise TOKEN_INVALID unless @user && @user.password_reset_generated_at > 4.hours.ago

  rescue => e
    flash.alert = e.message

    redirect_to new_password_path(email: @user.try(:email))
  end

  def update_password
    @token = params[:user][:password_reset_token]
    raise TOKEN_MISSING if @token.blank?

    @user = User.where(password_reset_token: @token).first
    raise TOKEN_INVALID unless @user && @user.password_reset_generated_at > 4.hours.ago

    @user.update_attributes!(password_params)

    flash.notice = "Password updated successfully."

    redirect_to login_path(email: @user.email)

  rescue ActiveRecord::RecordInvalid => e
    render 'edit_password'

  rescue => e
    flash.alert = e.message

    redirect_to new_password_path(email: @user.try(:email))
  end

  private
    def user_params
      params[:user].slice(:email, :facebook_identifier, :first_name, :last_name, :password, :password_confirmation, :profile_image_url, :gender, :date_of_birth)
    end

    def password_params
      params[:user].slice(:password, :password_confirmation)
    end
end
