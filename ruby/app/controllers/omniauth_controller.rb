class OmniauthController < ApplicationController
  skip_before_filter :authenticate
  skip_before_filter :verify_subscription
  skip_before_filter :accept_terms
  skip_before_filter :complete_onboarding

  def callback
    @auth = request.env['omniauth.auth']

    case @auth.provider
    when 'facebook'
      @uid = @auth.uid
      @email = @auth.info.email


      log "FACEBOOK AUTH CALLBACK for fid:#{@auth.uid} and email:#{@auth.info.email}  "

      if @user = User.find_by_facebook_identifier(@uid)
        log " FB AUTH: existing user found by facebook id - login"
        login_as(@user)
        redirect_to root_path and return
      end

      if @user = User.find_by_email(@email)
        log " FB AUTH: existing user found by email - login"

        # connect to existing user and login
        @user.facebook_identifier = @uid
        @user.save
        login_as(@user)
        redirect_to root_path and return
      end


      # Create a lead if no user is found
      log " FB AUTH: no user was found - login"
      create_or_update_lead(@email, params.merge({source:session[:source], campaign:session[:campaign], landing_page:session[:landing_page]}))

      @user = User.new do |u|
        u.facebook_identifier = @uid
        u.email = @email
        u.first_name = @auth.info.first_name
        u.last_name = @auth.info.last_name
        u.profile_image_url = @auth.info.image
        u.gender = @auth.extra.raw_info.gender
        u.date_of_birth = Date.strptime(@auth.extra.raw_info.birthday, '%m/%d/%Y')
      end

      # clear the email field in the login form
      @email = nil

      # let user choose
      render 'facebook'
    end
  end

  # only available in development environment
  def facebook_test
    @user = User.new
    render 'facebook'
  end

  def failure
    redirect_to(login_path, alert: params[:message])
  end
end
