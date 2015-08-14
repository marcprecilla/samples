include ProgressHelper
module ProgressViewHelper

  DailyPointsData = Struct.new(:timestamp_for_day, :day_of_week, :activities, :points)
 
  TimelineEntry = Struct.new(:type, 
    :plan, :action_item, 
    :activity,  :points, 
    :day_of_week, :timestamp_for_day)


	# attribute preparation
	def prepare_points_graph_attributes(enrollment)
    @graph_data = calc_points_graph_data(enrollment,8)
    @points_total = enrollment.points
    @points_this_week = enrollment.action_plans.last.points
    # puts @graph_data.collect{|i| [Time.at(i.first).to_date, i.last].join('     ->    ')}
	end

  def prepare_user_metrics(enrollment)
    @days_complete = enrollment.days_performed
    @longest_streak = enrollment.longest_consecutive_days_logged_in
    @number_of_guided_meditations = enrollment.events.completed_intervention.count
    @number_of_checkins = enrollment.events.checkins.count
  end

  def add_event_to_timeline(event, options={})
    points = options[:points] || event.points
    statement = " >> #{event.type}  #{event.created_at.to_s}"
    puts statement
    logger.debug statement

    # TimelineEntry = Struct.new(:type, :plan, :action_item,          :activity,  :points,         :day_of_week, :timestamp_for_day)
    @timeline << TimelineEntry.new(event.type, event.action_item.try(:action_plan), event.action_item, 
      options[:activity], points, 
      weekday_name_for(event.created_at), event.created_at.beginning_of_day.to_i)

  end
  private :add_event_to_timeline

  def prepare_timeline_attributes(enrollment, show_day_circles)
    @timeline = []
    last_event = nil

    enrollment.events.except_mixpanel.order("created_at DESC").limit(100).reverse.each do |event|
      item = event.action_item
      plan = item.try(:action_plan)

      unless item && plan
        log " Timeline: Skipping #{event.type} event as there is no attached action item (#{item}) or action plan (#{plan}) (currently required for this method, though it could be refactored)"
        next
      end

      puts "processing event for timeline: #{event.type}"


      if show_day_circles && (last_event.nil? || last_event.created_at.day != item.created_at.day)
        puts "new day"
        @timeline << TimelineEntry.new(:new_day, plan, item, nil, plan.points_for_day(item), weekday_name_for(event.created_at), event.created_at.beginning_of_day.to_i)
      end

      logger.info puts "     #{event.type.to_sym}?"

      case event.type.to_sym
      when :started_week
        # add_event_to_timeline event, points:plan.points_for_day(item)

      when :completed_assigned_intervention
        add_event_to_timeline event, activity:event.target

      when :intention_added, :intention_visualized, :thank_added, :thank_visualized, 
        :checkin,
        :completed_baseline_assessment, :completed_happy_face_intervention, :completed_360_assessment
        add_event_to_timeline event
      end

      last_event = item
      break if @timeline.count > 20
    end

    @timeline
  end


  # highest high low lowest
  def trend_indicator_for_change(change)
    if change > 15
      :highest
    elsif change > 0
      :high
    elsif change > -15
      :low
    else
      :lowest
    end
  end

	def prepare_metrics_and_insights_attributes(action_plan)
		@show_trends_and_analysis = trends_are_available?

    @focus_change = @positivity_change = @sleep_change = @social_change = nil

    @analysis={}

    if @show_trends_and_analysis
      previous_plan = action_plan.previous_action_plan
            
      @focus_change = previous_plan.focus_change
      @positivity_change = previous_plan.positivity_change
      @sleep_change = previous_plan.sleep_change
      @social_change = previous_plan.social_change

      @focus_change_indicator = trend_indicator_for_change @focus_change
      @positivity_change_indicator = trend_indicator_for_change @positivity_change
      @sleep_change_indicator = trend_indicator_for_change @sleep_change
      @social_change_indicator = trend_indicator_for_change @social_change

      @analysis[:focus] = previous_plan.focus_analysis
      @analysis[:positivity] = previous_plan.positivity_analysis
      @analysis[:sleep] = previous_plan.sleep_analysis
      @analysis[:social] = previous_plan.social_analysis
    
    else # has the baseline mini been taken?
      baseline_results = action_plan.enrollment.assessments.baseline.last.try(:results)
      if baseline_results
        @focus_change = 0 if ! baseline_results[:focus].nil?
        @positivity_change = 0 if ! baseline_results[:positivity].nil?
        @sleep_change = 0 if ! baseline_results[:sleep].nil?
        @social_change = 0 if ! baseline_results[:social].nil?
      end
    end
	end

  def calc_points_graph_data(enrollment, number_of_weeks)
    week_data = {}
    week = enrollment.week

    for week in week-(number_of_weeks-1)..week
      points_for_week(enrollment, week).each_with_index do |points, index|
        day = index+1
        sequential_date = ActionPlan.sequential_date_for(enrollment, week, day)
        week_data[sequential_date.beginning_of_day.to_i] = points
      end
    end
   week_data
  end

  def points_for_week(enrollment, week)
    return [0,0,0,0,0,0,0] unless week > 0
    (1..7).collect{ |day| points_for_day(enrollment, week, day) }
  end
  def points_for_day(enrollment, week, day) 
    enrollment.events.for_week_and_day(week,day).collect(&:points).compact.sum
  end

end
