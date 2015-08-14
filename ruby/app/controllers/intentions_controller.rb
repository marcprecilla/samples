class IntentionsController < ApplicationController
  skip_before_filter :verify_subscription

  include IntentionsHelper

  def index
    @intentions = current_enrollment.intentions[0..10]

    # flash[:notice] = "Please create an intention"
    path = new_intention_path
    if params[:show_desktop].present?
      path += '?show_desktop=1'
    end

    redirect_to path if @intentions.empty?

    if params[:show_desktop].present? && !@intentions.empty?
        render :layout => "layouts/application_ajax"
    end

  end

  def new
    @sample_intentions = some_sample_intentions(10, current_user)

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

  end

  def create
    new_intention = nil
    for intention_attributes in params[:intentions]
      text = intention_attributes[:text]
      color = intention_attributes[:color]

      next unless text && text.strip.length > 0

      # image urls come later
      new_intention = current_enrollment.intentions.create!(text:text, color:color) unless text.blank?
      # track_event(current_action_item(Intention::COMPONENT_TYPE)||current_enrollment, Intention::ADDED_EVENT, target:new_intention, points:INTENTION_POINTS, text:text, intention_uuid:new_intention.uuid)
      # current_enrollment.add_points!(INTENTION_POINTS)
   end

    # associate an open action item with the new event
    # find an open action item
    curr_ai = current_action_item(Intention::COMPONENT_TYPE)
    if curr_ai
      curr_ai.component_uuid=new_intention.uuid
      curr_ai.save!
    end

    track_event(curr_ai||current_enrollment, Intention::ADDED_EVENT,  target:new_intention, points:INTENTION_POINTS, text:text)

    redirect_to visionboard_path
  end

  def show
    @intention = Intention.find_by_uuid(params[:id])

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

  end

  #add images to the intention
  def update
    new_images = params[:images]||[]

    @intention = Intention.find_by_uuid(params[:id])
    @intention.image_urls = IntentionsHelper.strip_duplicate_images(new_images)
    @intention.save

    points = VISBD_INTENTION_IMAGE_POINTS*new_images.count
    track_event(current_action_item(Intention::COMPONENT_TYPE)||current_enrollment, Intention::VISUALIZED_EVENT, target:@intention, points:points)

    render nothing: true
  end


end
