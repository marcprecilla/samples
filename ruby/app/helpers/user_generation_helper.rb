include EventsHelper
include PointsHelper
module  UserGenerationHelper

  def simulate_user_activity(user_uuid, number_of_weeks)

    return unless stress_less_program = Program.where(name: "Stress Less").first
    return unless user = User.find_by_uuid(user_uuid)

    enrollment = Enrollment.where(program_uuid: stress_less_program.uuid, user_uuid: user_uuid).first_or_create

    unless enrollment.number_of_unique_activities_completed > 0
      enrollment.update_attribute(:created_at, past_timestamp(number_of_weeks,0))

      for week in 1..number_of_weeks
        puts "CREATING ACTION PLAN FOR WEEK #{week}"
        create_action_plan(user, week, enrollment)
      end if number_of_weeks > 1

      for week in 1..(number_of_weeks-1)
        puts "COMPLETING ACTION PLAN FOR WEEK #{week}"
        create_activity(user, week, enrollment)
      end if number_of_weeks > 1

    end
  end


  def create_action_plan(user, weeks_ago, enrollment)
    stress_less_program = Program.where(name: "Stress Less").first

    action_plan = StressLessAppWeeklyActionPlan.create_plan_for_week(weeks_ago, enrollment, stress_less_program)
    action_plan.created_at = past_timestamp(weeks_ago,0)
    action_plan.save!

    for action_item in action_plan.action_items
      # update the action_item date to the action_plan's date
      action_item.created_at = action_plan.created_at
      action_item.save!
    end
  end

  def create_activity(user, weeks_ago, enrollment)
    action_plan = user.current_action_plan
    
    for action_item in action_plan.action_items
      activity_date = past_timestamp(weeks_ago,action_item.day)
      activity = Activity.create({enrollment: user.current_enrollment, created_at: activity_date, 
        intervention_uuid:action_item.component_uuid,
        action_item_uuid:action_item.uuid}, without_protection: true)
      activity.save
      action_item.save!

      track_event(action_item, :completed_assigned_intervention, created_at:activity_date, updated_at:activity_date, mixpanel_name:'Completed Intervention', target: activity, points:COMPLETED_ASSIGNED_INTERVENTION_POINTS, intervention: action_item.intervention ? action_item.intervention.name : "not_set")
    end

    answer_check_in_questions action_plan, weeks_ago
  end

  def answer_check_in_questions(action_plan, weeks_ago)
    assessment = action_plan.checkin_assessment

    for action_item in action_plan.unanswered_check_in_questions
      points = answer_checkin_questions_for_action_item(action_item)

      created_at=past_timestamp(weeks_ago.weeks.ago, action_item.day)
      track_event(action_item, :checkin,  created_at:created_at, target:assessment, points:ANSWER_ASSESSMENT_QUESTION_POINTS, updated_at:created_at, number_of_questions:action_item.count)
    end
  end

  def answer_checkin_questions_for_action_item(action_item)
    check = action_item.check
    answer = rand(check.max_response_value)+1
    response=Response.new(assessment_uuid:assessment.uuid, check_uuid:check.uuid, value:answer)
    activity_date = past_timestamp(weeks_ago,action_item.day)
    response.created_at=activity_date
    response.save!
  end

  def destroy_check_in_questions(action_plan,category)
    case category.to_sym
    when :sleep
      action_plan.try(:destroy_check_in_action_items, CheckinAssessment::SLEEP_SUBCATEGORIES)
    when :positivity
      action_plan.try(:destroy_check_in_action_items, CheckinAssessment::POSITIVITY_SUBCATEGORIES)
    when :social
      action_plan.try(:destroy_check_in_action_items, CheckinAssessment::SOCIAL_SUBCATEGORIES)
    when :focus
      action_plan.try(:destroy_check_in_action_items, CheckinAssessment::FOCUS_SUBCATEGORIES)
    end
  end

  private
  def past_timestamp(weeks_ago,days_ago)
    (weeks_ago.weeks-days_ago.days).ago
  end


end