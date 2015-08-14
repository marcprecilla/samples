class VisionboardItemsController < ApplicationController
  skip_before_filter :verify_subscription

  include VisionboardHelper
  include ProgressViewHelper
  include BaselineAssessmentsHelper
  include ThreeSixtyAssessmentsHelper

  def index
    @menu_section = 'visionboard'
    @intentions = current_enrollment.intentions.limit(50)
    @thanks = current_enrollment.thanks.limit(50)
    @items = (@intentions+@thanks).sort{|a,b| b.created_at <=> a.created_at}[0..50]

    if desktop?
      @user = current_user

      @enrollment = current_enrollment
      prepare_points_graph_attributes(current_enrollment)

      prepare_user_metrics(current_enrollment)
      prepare_timeline_attributes(current_enrollment, false)

      prepare_baseline_assessment_attributes(current_enrollment)
      prepare_metrics_and_insights_attributes(current_action_plan)
      prepare_three_sixty_assessment_attributes(current_enrollment)


      @latest_activity = @enrollment.latest_activity


      if params[:show_desktop].present?
          render :layout => "layouts/application_ajax"
      else
        render :layout => "layouts/application_desktop", :action => "desktop_index"
      end
    end

  end
end
