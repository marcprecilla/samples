class ActionPlanController < ApplicationController
  include InterventionHelper
  include ActionPlanHelper
  include ProgressViewHelper
  include BaselineAssessmentsHelper
  include ThreeSixtyAssessmentsHelper

  skip_before_filter :verify_subscription, only: [:index]
  # skip_before_filter :complete_onboarding

  def index
    # verify_subscription and return unless desktop?

    @current_week = current_week
    @current_day = current_day
    @day = params[:day] ? params[:day].to_i : current_day

    @week = params[:week].try(:to_i) || current_week
    if params[:week]
      @plan = current_enrollment.action_plans[@week-1]
    else
      # if the week parem is set, then use that week
      @plan = current_action_plan # nudge the creation of a new week's plan if appropriate
    end


    # show the recently completed day instead of the new day, unless overridden
    yesterday_completed_at = @plan.day_completed_at(@current_day-1)
    @user_has_just_completed_the_days_activities = (!yesterday_completed_at.nil?) && (yesterday_completed_at  > 2.hour.ago) # current_day have been updated
    if params[:force].nil? && params[:day].nil? && params[:week].nil? && @user_has_just_completed_the_days_activities && @current_day != 1 && (!@plan.started_current_day?)
      @day = @current_day - 1
    end

    @showing_current_day = (@day == current_day && @week == current_week)

    @days_until_next_action_plan = ((Time.now-@plan.created_at)/1.day).to_i + 1
    @show_week_splash_page = @day == 1 && @plan.completed_action_items.empty? && params[:day].nil?

    # if the day is set, then the user has clicked on a previous day and the check should be "unskipped" if they were skipped
    @force_checkin_day = params[:day]

    @enrollment = current_enrollment

    @username = current_user.name
    load_intervention_metadata

    @interventions = { "Positivity" => [], "Focus" => [], "Social" => [], "Sleep" => [] }
    Intervention.all.each { |intervention| @interventions[category_for_intervention_sym intervention.key.to_sym] << intervention }

    @current_action_plan_points = @plan.points

    @intervention_action_item = @plan.action_items.for_day(@day).prescribed.interventions.first
    @visionboard_action_item = @plan.action_items.for_day(@day).visionboard.first
    @checkin_action_item = @plan.action_items.for_day(@day).checks.first
    @baseline_assessment_action_item = @plan.action_items.for_day(@day).baseline_assessments.first
    @three_sixty_assessment_action_item = @plan.action_items.for_day(@day).three_sixty_assessments.first

    # 360
    baseline_assessment = current_enrollment.assessments.baseline.last
    three_sixty_assessment = current_enrollment.assessments.three_sixty.last
    three_sixty_assessment_is_complete = three_sixty_assessment && three_sixty_assessment.complete?

    #  OLD # 360 becomes available one week after the baseline assessment, which is available on week two (actually, week 1, day 7),
    # # so anytime after this point, show the three sixty link until it is completed.
    # @show_three_sixty_link = baseline_assessment && baseline_assessment.complete? && !three_sixty_assessment_is_complete

    # 360 becomes available as soon as the baseline mini is taken
    @show_three_sixty_link = baseline_assessment && baseline_assessment.mini_complete? && !three_sixty_assessment_is_complete

    @remaining_questions_count = @plan.unanswered_check_in_questions.count

    # note that @checkin_type will be nil for older checkins (pre-Eddie).
    @checkin_type = @checkin_action_item.try(:checkin_type)

    #iterate through days to get their status for navigation (complete, incomplete, current)
    @day_navigation_states = []
    for i in 1..7
      action_item_complete = true
      current_state = ""
      @current_intervention_action_item = @plan.action_items.for_day(i).prescribed.interventions.first
      @current_visionboard_action_item = @plan.action_items.for_day(i).visionboard.first
      @current_checkin_action_item = @plan.action_items.for_day(i).checks.first
      if @current_intervention_action_item
        if !@current_intervention_action_item.performed?
          action_item_complete = false
        end
      end
      if @current_visionboard_action_item
        if !@current_visionboard_action_item.performed?
          action_item_complete = false
        end
      end
      if @current_checkin_action_item
        if !@current_checkin_action_item.performed?
          action_item_complete = false
        end
      end

      if i <= @current_day
        if action_item_complete
          current_state += " complete "
        else
          current_state += " incomplete "
        end
      end

      if i== @day
        current_state += " current "
      end

      @day_navigation_states.push(current_state)
    end

    @intervention = @intervention_action_item ?  @intervention_action_item.intervention : nil

    # show walkthroughs for first session
    @show_action_plan_walkthrough = false
    if session.delete(:show_action_plan_walkthrough)
      @show_action_plan_walkthrough = true
    end

    @menu_section = 'toolkit'

    # @baseline results, @focus_score, @positivity_score, @sleep_score, @social_score
    prepare_baseline_assessment_attributes(current_enrollment)
    @personality_results = current_enrollment.assessments.pre_paywall.first.try(:results)



    if desktop? || browser.tablet?
        @user = current_user

        #visionboard
        @intentions = current_enrollment.intentions.limit(50)
        @thanks = current_enrollment.thanks.limit(50)
        @items = (@intentions+@thanks).sort{|a,b| b.created_at <=> a.created_at}[0..50]

        @enrollment = current_enrollment
        prepare_points_graph_attributes(current_enrollment)

        prepare_user_metrics(current_enrollment)
        prepare_timeline_attributes(current_enrollment, false)

        prepare_metrics_and_insights_attributes(current_action_plan)
        prepare_three_sixty_assessment_attributes(current_enrollment)


        @latest_activity = @enrollment.latest_activity

        if current_user && current_user.stripe_subscription_active?
          track_event(current_enrollment, :dashboard_view, week: current_week, day:current_day)
          render :layout => "layouts/application_desktop", :action => "desktop_dashboard"
        else
          track_event(current_enrollment, :free_dashboard_view, {})
          render :layout => "layouts/application_desktop", :action => "desktop_dashboard_free"
        end

    end
  end


  # NOTE: works on current action plan only
  def skip_day
    current_action_plan.skip_day(current_day)
    track_event(current_enrollment, :skipped_day, week: current_week, day:current_day)
    redirect_to action_plan_index_path(force:true)
  end

end
