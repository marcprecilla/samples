class SendIntentionNudge
  @queue = :low

  def self.perform(user_uuid)
    return unless user = User.find_by_uuid(user_uuid)

    # send_email_nudge(user) if user.receive_email_notifications
    send_sms_nudge(user) if user.receive_sms_notifications
  end

  def self.send_sms_nudge(user)
    phone = user.mobile_phone
    return if phone.blank?

    long_code = TWILIO_LONG_CODES.first

    intention = find_an_appropriate_intention(user)
    return unless intention

    message = generate_sms_message(user, intention)

    track_event(user.current_enrollment, :sent_nudge,  nudge_type: :intention_nudge, mode: :sms, message:message, target:intention)

    # send SMS
    TWILIO_CLIENT.account.sms.messages.create(from: long_code, to: phone, body: message)
  end

  def self.generate_sms_message(user, intention)
    visionboard_url = Api::Bitly.shorten(Rails.application.routes.url_helpers.visionboard_url(protocol: PROTOCOL, host: HOST))
    "This week, remember your intention to be #{intention.text}. -app #{visionboard_url}"
  end

  # use a random intention, excluding an intention that was sent the last time
  def self.find_an_appropriate_intention(user)
    intentions = user.current_enrollment.intentions

    # TODO: look for the previously sent intention and see if we have a previous intention sms in the last week
    last_weeks_intentions = user.current_enrollment.events.since(1.week.ago).of_type('sent_nudge').where(target_type:'Intention').collect(&:target)

    remaining = intentions - last_weeks_intentions
    selected_intention = remaining.sample
    selected_intention
  end


end
