module EventsHelper


  # target
  # points
  # created_at, updated_at - for testing 
  #
  # e.g.
  # track_event(current_enrollment, :checkin,  target:current_action_plan.checkin_assessment, points:points, number_of_questions:answers.count)
  def track_event(enrollment_or_lead_or_action_item, event_type, data)
    Rails.logger.warn "Cannot track the event #{event_type}" and return unless enrollment_or_lead_or_action_item

    track_mixpanel_event_for_lead(enrollment_or_lead_or_action_item, event_type, data) and return if enrollment_or_lead_or_action_item.kind_of?(Lead)

    action_item = enrollment = nil
    if enrollment_or_lead_or_action_item.kind_of?(ActionItem)
      action_item = enrollment_or_lead_or_action_item
      enrollment = action_item.action_plan.enrollment
    else # no action item is associated with the event
      enrollment = enrollment_or_lead_or_action_item
    end

    event_title = event_type.to_s.titleize
    event_caps = event_type.to_s.upcase

    creation_params = {type: event_type, enrollment_uuid:enrollment.try(:uuid)}
    creation_params[:action_item_uuid] = action_item.uuid if action_item
    creation_params[:points] = data.delete(:points) if data.has_key?(:points)
    creation_params[:created_at] = data.delete(:created_at) if data.has_key?(:created_at)
    creation_params[:updated_at] = data.delete(:updated_at) if data.has_key?(:updated_at)

    target = data.delete(:target)
    creation_params[:target_type] = target.class.to_s if target
    creation_params[:target_uuid] = target.uuid if target

    mixpanel_name = data[:mixpanel_name] || event_type.to_s.titleize

    e=Event.create(creation_params)#type: event_type, enrollment_uuid:enrollment.uuid, target_type:target_type, target_uuid:target.uuid, data:data_hash, points:points)
        
    mixpanel_track_with_target(enrollment, mixpanel_name, data)
    e
  end

  def track_mixpanel_event_for_lead(lead, event_type, data)
    a(lead,"track_event_for_lead EXCEPTION")
    return unless lead

    event_title = event_type.to_s.titleize
    mixpanel_name = data[:mixpanel_name] || event_type.to_s.titleize
    target = data.delete(:target)
        
    mixpanel_track_with_target(lead, mixpanel_name, data)
  end


  # e.g.  mixpanel_track_with_target(current_enrollment, 'An Event', {week: week} )
  # target is either a lead or an enrollment object
  def mixpanel_track_with_target(target, user_friendly_event_type, props)
    log "I'm sending an event to Mixpanel (#{user_friendly_event_type}), target=#{target}, \nprops=#{props.to_yaml}"

    return unless target
    mp_user_id = nil
    event_type = "mix_panel_#{user_friendly_event_type.to_s.downcase.tr(' ', '_')}"

    event_creation_args = {type:event_type, data:props}

    if target.kind_of? Enrollment
      event_creation_args[:enrollment_uuid] = target.uuid
    elsif target.kind_of? Lead
      event_creation_args[:lead_uuid] = target.email
    else
      raise "invalid target for mixpanel_track_with_target: #{target.class.to_s}"
    end

    Event.create event_creation_args
    begin
      track_in_mixpanel(target, user_friendly_event_type, props)
    rescue Exception => e
      Rails.logger.error "Failed to talk to mixpanel: #{e.message}"
    end
    log "  ...I've finished sending an event to Mixpanel"
  end


end