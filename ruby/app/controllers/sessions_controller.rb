require 'bcrypt'

class SessionsController < ApplicationController
  before_filter :ie_cutoff, only: [:new]
  skip_before_filter :authenticate, :accept_terms, :complete_onboarding, :verify_subscription

  def new
    @email = params[:email]
    @password = nil

    # use facebook as auth source
    if params[:method] == 'facebook'
      redirect_to '/auth/facebook' and return
    end

    if current_user && (@email.nil? || current_user.email == @email)
      redirect_to action_plan_index_path and return
    end
  end

  def create
    @email = params[:email]
    @password = params[:password]

    # try to find user
    @user = User.where(email: @email).first!
    raise SecurityError unless @user.authenticate(@password)

    # make sure the lead is in session if there is one with this email. 
    remember_lead(Lead.find_by_email(@email)) unless @user

    # copy user data from facebook
    read_facebook_user_data
    @user.save if @user.changed?

    login_as(@user)
    
    case @return_path = params[:return_path]
    when nil, 'facebook'
      redirect_to(previous_location || action_plan_index_path)
    else
      redirect_to(previous_location || @return_path)
    end

rescue SecurityError, ActiveRecord::RecordNotFound => e
    message = 'An account with that email and password combination cannot be found.'

    case @return_path = params[:return_path]
    when nil
      flash.now.alert = message
      render 'new'
    when new_subscription_path
      @user = nil
      @selected_tab = 'login-tab'
      flash.now.alert = message
      render 'subscriptions/new'
    when 'facebook'
      @user = User.new
      read_facebook_user_data
      flash.now.alert = message
      render 'omniauth/facebook'
    else
      flash.alert = message
      redirect_to @return_path
    end
  end

  def destroy
    logout and redirect_to login_path
  end

private
  
  def read_facebook_user_data
    return unless @user
    @user.first_name ||= params[:first_name]
    @user.last_name ||= params[:last_name]
    @user.facebook_identifier ||= params[:facebook_identifier]
    @user.profile_image_url ||= params[:profile_image_url]
    @user.gender ||= params[:gender]
    @user.date_of_birth ||= params[:date_of_birth]
  end

end
