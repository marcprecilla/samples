class ActivityController < ApplicationController
  include InterventionHelper

  def index
    @window_title = 'Activity Feed'
    @menu_section = 'activity-feed'

    @enrollment = current_enrollment
    @user = @enrollment.user

    @activities = @enrollment.activities
    @menu_section = 'activity-feed'

    @events = [@activities,@enrollment.action_plans].flatten.sort { |a,b| a.created_at <=> b.created_at }#.collect(&:created_at)
 end

  def show
    @enrollment = current_enrollment
    @activity = Activity.find_by_uuid(params[:id])

    render(text:"couldn't find an activity with that uuid", status: :not_found) and return unless @activity

    @intervention = @activity.intervention

    # latest_activity = @enrollment.latest_activity_for_intervention(@intervention)
    latest_activity = @enrollment.activities.where(intervention_uuid:@intervention.uuid).where(['uuid <> ?', @activity.uuid]).order("created_at DESC").first

    @show_feedback = latest_activity ? (latest_activity.created_at < 8.weeks.ago) : true

    if desktop?
        render :layout => "layouts/application_ajax"
    end

  end

  # called only for repeat activities
  def new
    @enrollment = current_enrollment
    @user = @enrollment.user

    @intervention = Intervention.where(key:params[:intervention_key]).first
    raise "invalid intervention #{params[:intervention_key]}" unless @intervention

    @action_plan = current_action_plan
    @action_item = @action_plan.action_items.where(component_uuid:@intervention.uuid).first

    # support "extra credit" activities
    if @action_item.nil?
      @action_item = ActionItem.create(component_type:Intervention::COMPONENT_TYPE, component_uuid:@intervention.uuid, prescribed:false)
      @action_plan.action_items << @action_item
      track_event(@action_item, :started_extra_credit_intervention,  target: @intervention, points:STARTED_EXTRA_CREDIT_INTERVENTION_POINTS, intervention: @intervention.name)
    else
      # todo: typo here, but shouldn't change or we will lose the continuity of Mixpanel events
      track_event(@action_item, :started_planned_intervention_intervention,  target: @intervention, points:STARTED_ASSIGNED_INTERVENTION_POINTS, intervention: @intervention.name)
    end

    if params[:show_desktop].present?
      redirect_to url_for_new_intervention(@intervention.key) + '?show_desktop=1'
    else
      redirect_to url_for_new_intervention(@intervention.key)
    end

  end


  def create
    intervention_uuid = params[:intervention_uuid]
    raise "Dev error #264nf3ri3nb: Need to provide an intervention id to create an activity." unless intervention_uuid

    @enrollment = current_enrollment
    @action_plan = current_action_plan

    @action_item = @action_plan.action_items.where(component_uuid:intervention_uuid).first
    @activity = @action_plan.latest_activity

    incomplete_count_before = @action_plan.incomplete_action_items.count

    @activity = Activity.create!(
      action_item:@action_item,
      enrollment:@enrollment,
      intervention_uuid:@action_item.intervention.uuid,
      text:params[:description],
      image_urls:params[:images])


    if @action_item.prescribed?
      track_event(@action_item, :completed_assigned_intervention,  mixpanel_name:'Completed Intervention', target: @activity, points:COMPLETED_ASSIGNED_INTERVENTION_POINTS, intervention: @action_item.intervention.name)
    else
      track_event(@action_item, :completed_extra_credit_intervention,  mixpanel_name:'Completed Intervention', target: @activity, points:COMPLETED_EXTRA_CREDIT_INTERVENTION_POINTS, intervention: @action_item.intervention.name)
    end

    # if this was the first activity of the week (i.e. for a new action) then
    if @action_plan.activities.count == 1
      logger.info "Started Week #{@action_plan.week}"
      # mixpanel_track( 'Started Week', {week: @action_plan.week} )
      track_event(@action_item, :started_week, {week: @action_plan.week} )
    end

    incomplete_count_now = @action_plan.incomplete_action_items.count

    # if the newly completed item was prescribed and completes the action plan then fire activity
    if incomplete_count_before - incomplete_count_now == 1 && incomplete_count_now == 0
      logger.info "Completed Week #{@action_plan.week}"
      # mixpanel_track( 'Completed Week', {week: @action_plan.week} )
      track_event(@action_item, :completed_week, {week: @action_plan.week} )
    end

    redirect_to activity_path @activity
  end

end
