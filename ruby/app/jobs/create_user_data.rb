include UserGenerationHelper

class CreateUserData
  @queue = :low

  def self.perform(user_uuid, number_of_weeks)
    self.simulate_user_activity(user_uuid, number_of_weeks)

    # return unless stress_less_program = Program.where(name: "Stress Less").first
    # return unless user = User.find_by_uuid(user_uuid)

    # enrollment = Enrollment.where(program_uuid: stress_less_program.uuid, user_uuid: user_uuid).first_or_create

    # unless enrollment.number_of_unique_activities_completed > 0
    #   enrollment.update_attribute(:created_at, week.weeks.ago)

    #   plan = StressLessAppWeeklyActionPlan.create_initial_action_plan(enrollment,stress_less_program)

    #   generate_check_in_questions(action_plan,type)

    #   (1..week).each do |week|
    #     create_activity(user, week, enrollment, stress_less_program)
    #   end
    # end
  end



  # private
  # def self.create_activity(user, week, enrollment, program)
  #       intervention_keys = StressLessAppWeeklyActionPlan.intervention_keys_for_week week, enrollment
  #       action_plan = StressLessAppWeeklyActionPlan.create_plan_with_interventions(intervention_keys, enrollment, program, week)

  #       action_plan.action_items.each do |action_item|
  #         activity_date = week.weeks.ago
  #         activity = Activity.create({enrollment: enrollment, created_at: activity_date, action_item_uuid:action_item.uuid}, without_protection: true)
  #         activity.save
  #         action_item.save
  #       end
  # end
end
