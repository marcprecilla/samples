include ProgressHelper

# This action plan subclass is very much app-specific
class StressLessAppWeeklyActionPlan < ActionPlan


  # vitality is week one, otherwise cycle through these...
  WEEK_ORDER = %w{ creativity  strength  curiosity  flow  strengths  meaningful  values  rejuvenation  happiness  love  leadership  growth}.collect(&:to_sym)

  INTERVENTION_PLAN = {
    vitality: [:diaphragmatic_breathing, nil, nil, :savoring_album_meal, :sleep_intervention_2, nil, :no_complaining],
    creativity: [:savoring_album_sight, nil, nil,:thank_bank_personal_interests, nil, nil,:body_awareness_meditation],
    strength: [:thank_you_day, nil, nil,:thank_bank_relationships,:sleep_intervention_3, nil,:progressive_muscle_relaxation],
    curiosity: [:interacting_with_nature, nil, nil,:change_something_location, nil, nil,:savoring_album_sound],
    flow: [:change_something_object, nil, nil,:thank_bank_work, nil, nil,:equal_breathing],
    strengths: [:body_awareness_meditation, nil, nil,:thank_bank_health, nil, nil,:savoring_album_touch],
    meaningful: [:thank_bank_personal_interests, nil, nil,:savoring_album_smell, nil, nil,:mindfulness_meditation],
    values: [:gratitude_meditation, nil, nil,:body_awareness_meditation, nil, nil,:compassion_meditation],
    rejuvenation: [:sleep_intervention_1, nil, nil,:breath_counting, nil, nil,:sleep_intervention_3],
    happiness: [:thank_you_day, nil, nil, :thank_bank_relationships, nil, nil, :gratitude_meditation], 
    love: [:compassion_meditation, nil, nil, :no_complaining, :equal_breathing, nil, :change_something_location], 
    leadership: [:thank_bank_work, nil, nil, :compassion_meditation, :change_something_object, nil, :thank_you_day], 
    growth: [:best_future_visualization, nil, nil, :mindfulness_meditation, :savoring_album_meal, nil, :gratitude_meditation] 
  }

  validates :week, presence: true

  attr_accessible :checkin_assessment_uuid

  belongs_to :checkin_assessment, primary_key: 'uuid', foreign_key: 'checkin_assessment_uuid', dependent: :destroy
  delegate :score, to: :checkin_assessment, allow_nil:true

  def self.current_action_plan(enrollment, program)
    # if the action plan is a more than a week old and the previous action plan is complete, then generate a new action plan
    last = enrollment.action_plans.last
    if last
      if last.complete?
        create_next_action_plan(enrollment, program) # will create the subsequent action plan
      else
        # return the current action plan
        last
      end
    else
      create_next_action_plan(enrollment, program) # will create an initial action plan
    end
  end


  def self.create_next_action_plan(enrollment, program, send_email=true)
    last_plan = enrollment.action_plans.last
    last_week = last_plan ? last_plan.week : 0

    user = enrollment.user
    week = last_week + 1

    plan = create_plan_for_week(week, enrollment, program)
    Resque.enqueue(SendWeeklyActionPlanEmail, user.uuid, self.theme_symbol_for_week(week)) if send_email

    return plan
  end


  def self.create_plan_for_week(week, enrollment, program)

    # create a new checkin assessment for any upcoming checkin questions
    checkin_assessment = CheckinAssessment.create!(enrollment_uuid:enrollment.uuid)

    plan = StressLessAppWeeklyActionPlan.create!(enrollment_uuid:enrollment.uuid, program_uuid:program.uuid, week: week, checkin_assessment_uuid:checkin_assessment.uuid)

    for day in 1..7
      plan_info = action_item_info_for(enrollment, week, day)
      if key = plan_info[:intervention]
        plan.create_intervention_action_item(day, key, true)
      end

      if category =plan_info[:checkin]
        plan.create_check_in_action_items(day, true)
      end

      if vb_type = plan_info[:vision_board]
        plan.create_vision_board_action_item(day, vb_type, true)
      end

      if plan_info[:baseline_assessment]
        plan.create_baseline_assessment_action_item(day, true)
      end

      if plan_info[:three_sixty_assessment]
        plan.create_three_sixty_assessment_action_item(day, true)
      end

    end

    #plan.save!
    plan
  end

  def self.theme_symbol_for_week(week)
    return :vitality if week == 1
    
    #otherwise loop through WEEK_ORDER
    WEEK_ORDER[week % (WEEK_ORDER.length)-2]
  end

  def self.intervention_keys_for_week(week)
    theme = theme_symbol_for_week week
    INTERVENTION_PLAN[theme]
  end

  def self.intervention_key_for(week, day)
    intervention_keys_for_week(week)[day-1]
  end

  def self.checkin_category_for_day(day)
    case day.to_i
    when 2; :sleep
    when 3; :positivity
    when 5; :social
    when 6; :focus
    else
      nil
    end
  end

  def self.action_item_info_for(enrollment, week, day)
    info = {intervention: nil, vision_board: nil, checkin: checkin_category_for_day(day)}

    case day
    when 1
        info[:vision_board] = Intention::COMPONENT_TYPE
    when 2
        info[:vision_board] = Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
    when 3
        info[:vision_board] = Thank::COMPONENT_TYPE
    when 4
        info[:vision_board] = Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
    when 5
    when 6
    when 7
        # noop
    else
    end

    # Baseline assessment
    baseline_assessment = enrollment.assessments.baseline.last
    if day == 7
      # if the user has an uncompleted baseline assessment, then add the AI to complete it.
      # if it is week one, day seven, then the baseline assessment AI is initially added.
      info[:baseline_assessment] = baseline_assessment.nil? || baseline_assessment.incomplete?
    end

    # 360 assessment
    puts "day, week = #{day}, #{week}"
    puts "sequential_day_for(week,day) = #{sequential_day_for(week,day)}"
   if baseline_assessment && baseline_assessment.mini_complete? && sequential_day_for(week,day) >= 14 &&  day == 7 
      # create an action item only once, the soonest possibe is day 14 which is one week after the baseline assessment can be taken
        puts "ADDING 360 AI unless the three sixty is old enough (#{baseline_assessment.last_answered < 1.week.ago}).  It must be created one week ago."
        info[:three_sixty_assessment] = true   # TODO for test# baseline_assessment.completed_at < 1.week.ago
    end

    info[:intervention] = intervention_key_for(week, day)
    info
  end



  def create_intervention_action_item(day, key, prescribed=true)
    logger.info " ==>>> create_intervention_action_item(day:#{day}, key:#{key})"
    intervention = Intervention.where(key:key).first
    action_items.create(component_type:Intervention::COMPONENT_TYPE, component_uuid:intervention.uuid, day:day, prescribed:prescribed)
  end

  def create_vision_board_action_item(day, vb_type, prescribed=true)
    logger.info " ==>>> create_vision_board_action_item(day:#{day}, vb_type:#{vb_type})"
    action_items.create(component_type:vb_type, component_uuid:nil, day:day, prescribed:prescribed)
  end

  def create_check_in_action_items(day, prescribed=true)
    category = self.class.checkin_category_for_day(day)
    return unless category

    logger.info " ==>>> create_check_in_action_items(day:#{day}, category:#{category})"

    # subcategories are focus_1, etc, for the category of :focus
    subcategories = CheckinAssessment::SUBCATEGORIES[category]
    raise "invalid checkin category: #{category} " unless subcategories

    subcategories.each do |subcategory|
      create_check_in_action_item_with_subcategory(day, subcategory, prescribed)
    end
  end

  def create_check_in_action_item_with_subcategory(day, category, prescribed=true)
    raise "checkin_assessment is nil and shouldn't be!" if checkin_assessment.nil?
    check = Check.where(check_type: "check-in", category:category).sample
    action_items.create(component_type:Check::COMPONENT_TYPE, component_uuid:check.uuid, day:day, prescribed:prescribed)
  end

  def create_baseline_assessment_action_item(day, prescribed=true)
    # Note: if there is an "unexpored"/recent baseline assessment, then it could be associated with the action item here,
    # but if that assessment expires before the action item is completed, then it is a bit bogis.  So I'm leaving the 
    # component_uuid blank at this point in time.

    action_items.create(component_type:BaselineAssessment::COMPONENT_TYPE, component_uuid:nil, day:day, prescribed:prescribed)
  end

  # NOTE: Deciding to create the 360 assement here and associate it with the baseline assessment
  def create_three_sixty_assessment_action_item(day, prescribed=true)
    baseline_assessment = enrollment.assessments.baseline.last
    raise "Developer error: Cannot find a baseline assessment, but we are trying to create a 360 assessment." unless baseline_assessment

    action_items.create(component_type:ThreeSixtyAssessment::COMPONENT_TYPE, component_uuid:nil, day:day, prescribed:prescribed)
  end


  def destroy_check_in_action_items(categories, only_unanswered=true)
    check_uuids = Check.where(category: categories).pluck(:uuid)
    action_items.where(component_uuid: check_uuids).find_each do |i|
      i.destroy unless (only_unanswered && i.complete?)
    end
  end


  # PROGRESS AND ANALYSIS EVALUATION
  def focus_change; change_for :focus; end
  def positivity_change; change_for :positivity; end
  def sleep_change; change_for :sleep; end
  def social_change; change_for :social; end

  def change_for(category)
    category = category.to_sym

    @this_plan_score ||= score
    @last_plan_score||= previous_action_plan.try(:score)

    return nil unless @last_plan_score # need two score sets
    return nil unless @last_plan_score[category] && @this_plan_score[category]  # need two scores for category

    res = @last_plan_score[category] - @this_plan_score[category]

    res.to_i  # since the value range is one hundred, the percent change is equal to the score difference
  end

  def focus_analysis; analysis_statement(:focus, focus_change); end
  def positivity_analysis; analysis_statement(:positivity, positivity_change); end
  def sleep_analysis; analysis_statement(:sleep, sleep_change); end
  def social_analysis; analysis_statement(:social, social_change); end

  #    ..     checkin queries    ..
  def unanswered_check_in_questions
    action_items.where(component_type:Check::COMPONENT_TYPE, day:1..day.to_i).select{|i| !i.complete?}
  end

  def check_in_questions_for_day(day)
    action_items.where(component_type:Check::COMPONENT_TYPE, day:day.to_i)
  end

  def intentions
    action_items.intentions.where("component_uuid IS NOT NULL").collect(&:intention)
  end
  def thanks
    action_items.thanks.where("component_uuid IS NOT NULL").collect(&:thank)
  end

  def complete?
    older_than_one_week? && all_prescribed_items_complete?
  end

  def older_than_one_week?
    # for testing
    week_duration_for_test_in_secs = ENV['WEEK_DURATION_FOR_TEST_IN_SECS']
    if week_duration_for_test_in_secs
      week_duration_for_test_in_secs = week_duration_for_test_in_secs.to_i
      puts  "*** ENV['WEEK_DURATION_FOR_TEST_IN_SECS'] is set to #{week_duration_for_test_in_secs} and is overriding the 1-week--until-next-action-plan rule ***"
      older = created_at < week_duration_for_test_in_secs.seconds.ago
      older
    else
      created_at < 7.days.ago
    end
  end
  def all_prescribed_items_complete?
    ! action_items.collect(&:complete?).include?(false)
  end

  def self.index_for_week(week)
    (week-1) % ACTION_PLAN_DATA.length
  end


end
