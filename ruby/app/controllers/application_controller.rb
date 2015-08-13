class ApplicationController < ActionController::Base
  include ApplicationHelper
  include EventsHelper
  include PointsHelper

  protect_from_forgery

  # application flow filters
  before_filter :require_ssl
  before_filter :authenticate
  before_filter :verify_subscription
  before_filter :accept_terms
  before_filter :check_for_interstitials
  before_filter :complete_onboarding

  # logging filters
  before_filter :update_login_timestamps
  before_filter :capture_common_session_vars
  before_filter :log_session_data

private

  # ==================================================
  # lead methods
  # ==================================================

  def current_lead
    @current_lead ||= session[:lead_id] && Lead.find_by_id(session[:lead_id])
  end
  helper_method :current_lead
  
  def remember_lead(lead)
    session[:lead_id] = lead.try(:id)
  end

  # ==================================================
  # user methods
  # ==================================================
  
  def current_user
    @current_user ||= session[:user_uuid] && User.find_by_uuid(session[:user_uuid])
  end
  helper_method :current_user

  def login_as(user)
    if user
      session[:user_uuid] = user.uuid
      flash.notice = 'Login successful.'
    end
  end

  def logout
    session[:user_uuid] = nil
    clear_subscription_data

    flash.notice = "Logged out."
  end

  # ==================================================
  # lead/user utilities
  # ==================================================

  def copy_lead_info_to_user(user)
    return unless user && lead_info = session[:lead_info]

    user.name ||= lead_info[:name]
    user.gender ||= lead_info[:gender]
    user.date_of_birth ||= lead_info[:date_of_birth]
    user.relationship_status ||= lead_info[:relationship_status]
    # lead_info[:assessment_uuid] ???
  end
  
  def find_email
    subject = current_user || current_lead
    subject ? subject.email : ""
  end
  helper_method :find_email

  def find_name
    subject = current_user || current_lead
    subject ? subject.name : ""
  end
  helper_method :find_name

  # ==================================================
  # enrollment/action plan methods
  # ==================================================
  
  def current_enrollment
    return nil unless current_user
    @enrollment = Enrollment.where(program_uuid: stress_less_program.uuid, user_uuid: current_user.uuid).first

    if @enrollment.nil?
      log "I'm CREATING AN ENROLLEMENT"
      
      # Need to create a new enrollment and associated action plan
      @enrollment = Enrollment.create!(program_uuid: stress_less_program.uuid, user_uuid: current_user.uuid, last_seen:Time.now)
      
      assessment = current_lead ? current_lead.assessment : nil
      assessment.update_attributes(enrollment_uuid:@enrollment.uuid) if assessment

      # 2.26.14 gh: adding support for the mini baseline assessment as a pre-registration activity
      if baseline_assessment = find_baseline_assessment_from_session
        baseline_assessment.enrollment = @enrollment
        baseline_assessment.save!

        # send the results
        Resque.enqueue(SendMiniBaselineResultsEmail, baseline_assessment.uuid, session)
      end

      # create the initial action plan
      @action_plan = current_action_plan
    end

    @enrollment
  end
  helper_method :current_enrollment

  # todo: move this to Enrollment model!
  # two action plans with two complete checkin assessments are necessary
  def trends_are_available?
    return false unless current_enrollment && current_enrollment.action_plans.count > 2

    one_week_ago_plan = current_action_plan.previous_action_plan
    two_weeks_ago_plan = one_week_ago_plan.try(:previous_action_plan)
    return false unless one_week_ago_plan && two_weeks_ago_plan

    # each of the previous two weeks must have assessments and results
    one_week_ago_plan.checkin_assessment.complete? && two_weeks_ago_plan.checkin_assessment.complete?
  end

  def current_week
    current_action_plan.week
  end
  def current_day
    current_action_plan.day
  end

  def current_action_plan
    return @action_plan if @action_plan

    enrollment = current_enrollment
    return nil unless enrollment

    @action_plan = StressLessAppWeeklyActionPlan.current_action_plan(enrollment, stress_less_program)
  end
  helper_method :current_action_plan

  def current_action_item(type)
    ActionItem.find_active_action_item(current_enrollment, type)
  end
  helper_method :current_action_item


  # ==================================================
  # application flow
  # ==================================================

  def store_location
    session[:redirect_stack] ||= []
    session[:redirect_stack] << request.fullpath
  end

  def previous_location
    session[:redirect_stack].try(:pop)
  end

  # ==================================================
  # application flow filters
  # ==================================================
  
  def require_ssl
     log "NAV: Checking for SSL"
   # check for enviroment variable
    return unless ENV['REQUIRE_HTTPS']

    unless request.ssl?
      log "NAV OVERRIDE: Redirecting to https://#{request.host_with_port}#{request.fullpath}"
      redirect_to({:protocol => 'https://'}.merge(params), :flash => flash)
    end
  end

  def authenticate
    log "NAV: Checking authentication"
    unless current_user
      log "NAV  OVERRIDE: ...No user in session, so I'm storing the redirect_stack and redirecting to the login path"
      store_location

      # Note: 2.12.14 gh: I'changed the dashboard/index (root_path) to go to registration, rather than
      #  login when there is no user.  I'm thinking that I should update this as well at some point, but I'm
      #  not sure if it will cause other issues.  So if the desired path is to default to registration, nav to the root path
      #  instead of relying on this filter.
      redirect_to login_path
      
    else
      log "NAV  ...ok: #{current_user.email} is logged in"
    end
  end

  def verify_subscription
    log "NAV: Checking for a subscription"

    unless current_user
      log("NAV  ... I tried to to check for a subscription, but there is no user logged in, so I'm silently returning")
      return 
    end

    unless current_user.stripe_subscription_active?
      log "NAV OVERRIDE  ...and there is NO subscription, so I am redirecting the user to the new_subscription_path"
      redirect_to(new_subscription_path)
    else
      log "NAV  ...and found a subscription, so quietly returning"
    end 

  end

  # Terms must be accepted just after purchase
  def accept_terms
    if current_user && !current_user.subscription_plan_uuid.nil?
      log "NAV: Checking that this subscribed user has accepted terms"

      unless current_user.terms_accepted?
        log "NAV OVERRIDE: ...and the user HASNT, so I'm redirecting the user to the terms path"
        redirect_to terms_path and return false
      end
    end
  end

  def check_for_interstitials
    log "NAV: Checking if we should show the interstitial page"

    return unless session[:show_bookmark_page]

    log "NAV: ..and there is a session veriable set (#{session[:show_bookmark_page]}) which means that I should show the interstitial page."

    # render the appropriate bookmark page
    case
    when browser.android?
      # rendering of bookmark page MUST occur from the root_path
      log "NAV: ..an Android user"
      redirect_to root_path and return unless view_context.current_page? root_path
      render 'home/bookmark'
    when browser.iphone?, browser.ipad?, browser.ipod?
      if browser.safari?
        # @user_agent = request.env['HTTP_USER_AGENT'].downcase
        
        # rendering of bookmark page MUST occur from the root_path
        redirect_to root_path and return unless view_context.current_page? root_path
        render 'home/bookmark'
      end
    when browser.mac?, browser.windows?, browser.linux?
      # render 'home/desktop_interstitial'
    end

    # don't show your face around here again
    log "NAV: ..I'm clearing the :show_bookmark_page session variable since we have just processed it."
    session.delete(:show_bookmark_page)
  end

  def complete_onboarding
    log "NAV: Checking to see if we need to send the user to onboarding"

    # 2/11/14: The onboarding screens are now only used as a fallback for when the user is subscribed but doesn't 
    #    have the dempgraphics filled out. I.e. S/he hasn't taken the pre-purchase assessmsent
    if current_user && current_user.subscription_plan_uuid
      unless current_user.onboarding_completed?
        log "NAV: ..and we do since we don't have all the onboarding data, redirecting the user to the edit_user_path (#{edit_user_path})"
        redirect_to edit_user_path and return false
      end
    end
  end

  # only used by sessions_controller
  def ie_cutoff
    if browser.ie6? || browser.ie7? || browser.ie8? || browser.ie9?
      redirect_to no_ie_path
    end
  end

  # ==================================================
  # logging filters
  # ==================================================
  
  def capture_common_session_vars
    # merge omniauth params
    if request.env['omniauth.params']
      full_params = request.env['omniauth.params'].deep_merge(params).with_indifferent_access
    else
      full_params = params
    end

    session[:source] = full_params[:s] if full_params[:s].present?
    session[:campaign] = full_params[:c] if full_params[:c].present?
    session[:landing_page] = full_params[:lp] if full_params[:lp].present?

    # google analytics
    session[:source] = full_params[:utm_source] if full_params[:utm_source].present?
    session[:campaign] = full_params[:utm_campaign] if full_params[:utm_campaign].present?

    # offers
    session[:offer_code] = full_params[:offer_code] if full_params[:offer_code].present?

    # couponing
    session[:coupon_code] = full_params[:coupon_code] if full_params[:coupon_code].present?

    if full_params[:email].present?
      puts "CAPTURING EMAIL: #{full_params[:email]}"
      create_or_update_lead(full_params[:email], {source:session[:source], campaign:session[:campaign], landing_page:session[:landing_page]})
    end
  end

  def log_session_data
    Rails.logger.info session.to_yaml
  end


  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # this notes the user had activity in the system. It updates the enrollment.last_seen and
  # adds a new session event if the user hasn't been seen in a while. 
  def update_login_timestamps
    if current_enrollment && current_enrollment.last_seen # when an enrollment is created, it's last_seen value is set
      
      if current_enrollment.last_seen < 4.hour.ago # 4 hours is somewhat arbitrary
        current_enrollment.events.new_session.create
      end

      # note that there is activity (since this before filter happens for any activity)
      current_enrollment.update_attribute(:last_seen, Time.now)
    end
  end


  # ==================================================
  # MixPanel and Logging
  # ==================================================
  
  # e.g.  mixpanel_track( 'An Event', {week: week} )
  def mixpanel_track(event_type, props)
    mixpanel_track_with_target(current_enrollment || current_lead, event_type, props)
  end

  def mixpanel_alias(alias_value)
    push_mixpanel_event "mixpanel.alias('#{alias_value}');"
  end
  def push_mixpanel_event(string)
    (session[:mixpanel_events] ||= "") << string
  end

  # ==================================================
  # subscription crap
  # ==================================================
  
  def current_offer
    return @_offer if @_offer

    # find offer
    @_offer = Offer.where(token: session[:offer_code]).first if session[:offer_code]
    @_offer ||= Offer.where(uuid: session[:offer_uuid]).first if session[:offer_uuid]
    @_offer ||= Offer.where(uuid: current_user.offer_uuid).first if current_user

    # check if offer is available
    @_offer = nil unless @_offer.try(:available?)

    # use default offer
    @_offer ||= Offer.default

    return @_offer
  end
  helper_method :current_offer

  def current_plan
    @_plan ||= SubscriptionPlan.where(uuid: params[:plan_uuid]).first if params[:plan_uuid]
    @_plan ||= SubscriptionPlan.where(uuid: session[:selected_plan_uuid]).first if session[:selected_plan_uuid]

    session[:selected_plan_uuid] = @_plan.try(:uuid)

    return @_plan

  rescue Stripe::StripeError => e
    error = e.json_body[:error]
    Rails.logger.error error[:message]

    # todo: something useful
  end
  helper_method :current_plan

  def current_coupon
    @_coupon ||= Stripe::Coupon.retrieve(session[:coupon_code]) if session[:coupon_code]

  rescue Stripe::StripeError => e
    error = e.json_body[:error]
    Rails.logger.error error[:message]

    flash.alert = 'Supplied coupon code is not valid.'

    session[:coupon_code] = nil
  end
  helper_method :current_coupon

  def clear_subscription_data
    session[:offer_code] = nil
    session[:offer_uuid] = nil
    session[:selected_plan_uuid] = nil
    session[:coupon_code] = nil
  end


  # ==================================================
  # support for minibaseline as a preregistration activity
  # ==================================================
  def store_baseline_assessment_in_session(assessment)
    session[:baseline_assessment_uuid]=assessment.uuid
  end
  def find_baseline_assessment_from_session
    uuid = session[:baseline_assessment_uuid]
    uuid ? BaselineAssessment.find_by_uuid(uuid) : nil
  end

end
