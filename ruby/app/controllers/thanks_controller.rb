class ThanksController < ApplicationController
  skip_before_filter :verify_subscription

  def index
    @items = current_enrollment.thanks[0..10]

    path = new_thank_path
    if params[:show_desktop].present?
      path += '?show_desktop=1'
    end

    redirect_to path if @items.empty?

    if params[:show_desktop].present? && !@items.empty?
        render :layout => "layouts/application_ajax"
    end
  
  end


  def new
    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

  end

  def create
    new_thank = nil
    for intention_attributes in params[:thanks]
      text = intention_attributes[:text]
      color = intention_attributes[:color]

      next unless text && text.strip.length > 0

      # image urls come later
      new_thank = current_enrollment.thanks.create!(text:text, color:color) unless text.blank?
      # current_enrollment.add_points!(THANK_POINTS)
    end

    # associate an open action item with the new event
    # find an open action item
    # ai = current_action_plan.action_items.thanks.select(&:not_performed?).first
    curr_ai = current_action_item(Thank::COMPONENT_TYPE)
    if curr_ai
      curr_ai.component_uuid=new_thank.uuid
      curr_ai.save!
    end
    
    track_event(curr_ai||current_enrollment, Thank::ADDED_EVENT,  target:new_thank, points:THANK_POINTS, text:text)

    redirect_to visionboard_path
  end

  def show
    @thank = Thank.find_by_uuid(params[:id])
    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

  end

  #add images to the thank
  def update
    new_images = params[:images]||[]

    @thank = Thank.find_by_uuid(params[:id])
    @thank.image_urls = IntentionsHelper.strip_duplicate_images(new_images)
    @thank.save

    points = VISBD_THANK_IMAGE_POINTS*new_images.count
    track_event(current_action_item(Thank::COMPONENT_TYPE)||current_enrollment, Thank::VISUALIZED_EVENT,  target:@thank, points:points)

    render nothing: true
  end

end
