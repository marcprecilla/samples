class SendWelcomeSms
  @queue = :normal
  
  def self.perform(user_uuid)
  	return unless user = User.find_by_uuid(user_uuid)

  	phone = user.mobile_phone
  	return if phone.blank?

    url = Rails.application.routes.url_helpers.dashboard_url(protocol: PROTOCOL, host: HOST)
    short_url = Api::Bitly.shorten(url)

  	message = "Thank you for joining app! Bookmark this URL to enjoy the mobile experience: #{short_url}"
  	long_code = TWILIO_LONG_CODES.first

  	# send SMS
  	TWILIO_CLIENT.account.sms.messages.create(from: long_code, to: phone, body: message)
  end
end
