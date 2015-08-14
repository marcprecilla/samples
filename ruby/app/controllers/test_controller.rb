class TestController < ApplicationController
  # layout false
  include UserGenerationHelper

  http_basic_authenticate_with name: 'tester', password: 'titssp4t'

  skip_before_filter :authenticate, :accept_terms, :check_for_interstitials, :complete_onboarding, :verify_subscription, :capture_common_session_vars

  def dashboard
    @enrollment = nil
    if @current_user = current_user
      if @enrollment = @current_user.enrollments.where(program_uuid: stress_less_program.uuid).first
      end
    end

    @plan = current_action_plan
    @week = @plan ? @plan.week : 0
  end

  def set_week
    week = params[:week].to_i

    current_user.enrollments.destroy_all
    CreateUserData.perform(current_user.uuid, week)

    flash.notice = "At week #{params[:week]}."
    redirect_to test_path
  end

  def update_action_plan
    plan = current_action_plan
    how_many = params[:how_many].to_f
    plan.created_at = how_many.days.ago

    plan.save!

    flash.notice = "Updated action plan's created_at date to be #{plan.created_at}."
    redirect_to test_path
  end

  def reset_progress
    current_enrollment.action_plans.destroy_all
    
    # NOTE: this is also destroying and events previous to signup.  This may cause issues
    current_enrollment.events.destroy_all

    current_enrollment.activities.destroy_all
    current_enrollment.intentions.destroy_all
    current_enrollment.thanks.destroy_all
    current_enrollment.assessments.baseline.destroy_all
    current_enrollment.assessments.three_sixty.destroy_all

    # simulate that the enrollment was created a few minutes ago
    current_enrollment.update_attribute(:created_at,5.minutes.ago)
    current_enrollment.update_attribute(:updated_at,5.minutes.ago)

    flash.notice = "Removed all action plans for this user."
    redirect_to test_path
  end

  def advance_to_next_week
    current_enrollment.action_plans.last.skip_week
    redirect_to test_path
  end

  def destroy_current_user
    @current_user = current_user
    @current_user.destroy if @current_user
    session[:user_uuid] = nil

    flash.notice = "Current user deleted"
    redirect_to test_path
  end

  def destroy_session_data
    reset_session

    flash.notice = "Session data deleted."
    redirect_to test_path
  end

  def create_test_users
    Resque.enqueue(CreateTestUsers, params[:num_test_users])

    flash.notice = "Creating #{params[:num_test_users]} test users..."
    redirect_to test_path
  end

  def destroy_test_users
    Resque.enqueue(DeleteTestUsers)

    flash.notice = "Deleting test users..."
    redirect_to test_path
  end

  def send_welcome_message
    case params[:type].to_sym
    when :sms
      SendWelcomeSms.perform(current_user.uuid)
    when :email
      SendWelcomeEmail.perform(current_user.name, current_user.email)
    end

    redirect_to test_path
  end

  def send_action_plan_email
    SendWeeklyActionPlanEmail.perform(current_user.uuid, params[:type])

    redirect_to test_path
  end

  def send_quote_email
    if @current_user = current_user
      SendAuxilaryEmail.mail_quote_to current_action_plan, 1
      flash.notice = "Quote email has been sent."
    end
    redirect_to test_path
  end
  def send_second_quote_email
    if @current_user = current_user
      SendAuxilaryEmail.mail_quote_to current_action_plan, 2
      flash.notice = "Quote email has been sent."
    end
    redirect_to test_path
  end

  def send_text_email
    if @current_user = current_user
      SendAuxilaryEmail.mail_article_to [current_action_plan]
     flash.notice = "Text email has been sent."
    end

    redirect_to test_path
  end

  def send_video_email
    if @current_user = current_user
      SendAuxilaryEmail.mail_video_to [current_action_plan]
      flash.notice = "Video email has been sent."
    end

    redirect_to test_path
  end

  # ==================================================
  # visionboard items
  # ==================================================
  def generate_visbd_ai 
    case params[:type].to_s
    when Intention::COMPONENT_TYPE
      current_action_plan.try(:create_intention_action_item)
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      current_action_plan.try(:create_visionboard_intention_action_item)
    when Thank::COMPONENT_TYPE
      current_action_plan.try(:create_thank_action_item)
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      current_action_plan.try(:create_visionboard_thank_action_item)
    end

    render nothing: true
  end

  def destroy_visbd_items 
    current_action_plan.action_items.visionboard.destroy_all
    render nothing: true
  end

  def send_visbd_email
    SendVisionboardNotificationEmail.perform(current_action_plan.uuid, params[:type])
    render nothing: true
  end



  # ==================================================
  # check-in questions
  # ==================================================

  def send_check_in_nudge
    SendCheckin.perform(params[:type], current_action_plan.uuid, current_action_plan.week, params[:day])
    render nothing: true
  end

end
