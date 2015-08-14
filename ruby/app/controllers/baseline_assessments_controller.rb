class BaselineAssessmentsController < ApplicationController
  include BaselineAssessmentsHelper
  include ThreeSixtyAssessmentsHelper

  skip_before_filter :authenticate
  skip_before_filter :verify_subscription

  def new
    @window_title = 'Baseline Assessment'
    @menu_section = 'toolkit'  # TODO ?
    @user = current_user

    category = params[:category] # for the Baseline Mini Assessment
    @is_mini_assessment = ! category.nil?

    curr_ai = current_action_item(BaselineAssessment::COMPONENT_TYPE)
    event_type = category ? :user_or_lead_started_mini_baseline_assessment : :user_or_lead_started_baseline_assessment
    track_event(curr_ai||current_enrollment||current_lead, event_type, {} )

    @assessment = BaselineAssessment.find_unexpired_and_incomplete_assessment(current_enrollment) || BaselineAssessment.new
    @questions = category ? BaselineAssessment.checks_for_category(category) : @assessment.unanswered_checks
	end

  # 10/26/14 Add support the mini assessment as a pre-registration activity: The baseline assessment will be created in the db 
  #  without an enrollment uuid and the assessment uuid is saved in the session and attached to the user upon registration
  def create
    assessment = current_enrollment ? current_enrollment.assessments.baseline.last : nil
    if assessment.nil? || assessment.created_at < 1.month.ago
      logger.info "Creating a new baseline assessment"
      assessment = BaselineAssessment.create(enrollment_uuid:current_enrollment ? current_enrollment.uuid : nil)
    else
      logger.info "Found an existing assessment"
    end

    params[:answers].each do |question_uuid, answer|
      next if answer == "" # bypass enpty answers

      check = Check.find_by_uuid(question_uuid)
      throw "you must provide the uuid of the question (aka check)" unless check

      assessment.responses.create!(check_uuid:check.uuid, value:answer)
    end

    # The assessment is created now, but may not have an enrollment. If not, we add the assessment uuid to the session
    #   so that it can be attached to the user later on.
    if assessment.enrollment.nil?
      log "I have a newly-created baseline assessment, but no user, so I'm storing the assessment's uuid in session for later use."
      store_baseline_assessment_in_session(assessment)
    end

    # track the event
    curr_ai = current_action_item(BaselineAssessment::COMPONENT_TYPE)
    if assessment.complete?
      track_event(curr_ai||current_enrollment||current_lead, "completed_baseline_assessment",  target:assessment, points:BASELINE_ASSESSMENT_POINTS)
      redirect_to baseline_assessment_path(assessment)
    elsif curr_ai||current_enrollment
      track_event(curr_ai||current_enrollment||current_lead, assessment.mini_complete? ? :user_or_lead_completed_mini_baseline_assessment : :user_or_lead_answered_baseline_assessment_questions,  target:assessment)
      redirect_to action_plan_index_path
    else # no user, go to registration
      redirect_to registration_path
    end
  end

  def show
    @enrollment = current_enrollment
    @assessment = BaselineAssessment.where(uuid:params[:id]).first || @enrollment.assessments.baseline.last

    redirect_to new_baseline_assessment_path and return unless @assessment

    @menu_section = 'toolkit'

    # @baseline results, @focus_score, @positivity_score, @sleep_score, @social_score 
    prepare_baseline_assessment_attributes(current_enrollment)
    prepare_three_sixty_assessment_attributes(current_enrollment)

    # mixpanel_track( 'Viewed Baseline Assessment Results', {type: @results.nil? ? 'benefits' : 'personality & benefits' } )
    curr_ai = current_action_item(BaselineAssessment::COMPONENT_TYPE)
    track_event(curr_ai||current_enrollment||current_lead, :user_or_lead_viewed_baseline_assessment_results, {} )
  end


end
