class ProgressController < ApplicationController
  include ProgressViewHelper

  def index

    if desktop?
      redirect_to "/action_plan?skip_intro=1"
    end

    @window_title = 'Progress'
    @menu_section = 'progress'
    @enrollment = current_enrollment
    prepare_points_graph_attributes(current_enrollment)

    prepare_timeline_attributes(current_enrollment, true)
    prepare_metrics_and_insights_attributes(current_action_plan)

    @latest_activity = @enrollment.latest_activity

    # show walkthroughs for first session
    @show_progress_walkthrough = false
    if session.delete(:show_progress_walkthrough)
      @show_progress_walkthrough = true
    end

  end

end
