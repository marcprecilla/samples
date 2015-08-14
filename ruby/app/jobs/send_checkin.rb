class SendCheckin
  @queue = :low

  def self.perform(type, user_uuid, week, day)
    return unless user = User.find_by_uuid(user_uuid)

  	send_email_checkin(type.to_sym, user, week, day) if user.receive_email_notifications
  	send_sms_checkin(type.to_sym, user, week, day) if user.receive_sms_notifications
  end

  def self.send_email_checkin(type, user, week, day)
  	email = user.email
  	return if email.blank?

    name = ""
    name.concat(", " + user.first_name) unless user.first_name.blank?

  	case type
  	when :sleep
      subject = "Do you feel rested today#{name}?"
      greeting = "Good morning#{name}!"
      question = "Do you feel rested today?"
  	when :positivity
      subject = "Do you feel good about today#{name}?"
      greeting = "Good morning#{name}!"
      question = "Do you feel good about today?"
  	when :social
      subject = "Spent any quality time with friends lately#{name}?"
      greeting = "Good afternoon#{name}!"
      question = "Spent any quality time with friends lately?"
  	when :focus
      subject = "Is your mind wandering today#{name}?"
      greeting = "Good afternoon#{name}!"
      question = "Is your mind wandering today?"
  	end

    url = Rails.application.routes.url_helpers.new_checkin_url(protocol: PROTOCOL, host: HOST, week: week, day: day)

    m = Mandrill::API.new
    message = {
      subject: subject,
      from_email: 'no-reply@myapp.com',
      from_name: 'app Team',
      to:  [{email: email, name: user.name}],
      track_opens: true,
      track_clicks: true,
      url_strip_qs: true,
      preserve_recipients: false,
      global_merge_vars: [
        {name: 'FNAME', content: user.first_name},
        {name: 'LNAME', content: user.last_name},
        {name: 'EMAIL', content: email}, 
        {name: 'GREETING', content: greeting},
        {name: 'QUESTION', content: question},
        {name: 'RESPONSE_URL', content: url},
      ],
      google_analytics_domains: GA_DOMAINS,
      google_analytics_campaign: "sl_#{type}_checkin"
    }
    mandrill_template = 'question-nudge'

    track_event(user.current_enrollment, :sent_nudge,  nudge_type: :checkin_nudge, mode: :email, type:type)

    results = m.messages.send_template(mandrill_template, [], message)
  end

  def self.send_sms_checkin(type, user, week, day)
  	phone = user.mobile_phone
  	return if phone.blank?

    # todo: cache shortened URLs so we don't have to make call to Bitly everytime
    url = Rails.application.routes.url_helpers.new_checkin_url(protocol: PROTOCOL, host: HOST, week: week, day: day)
    short_url = Api::Bitly.shorten(url)

  	long_code = TWILIO_LONG_CODES.first
    message = generate_sms_message(type, user.first_name, short_url)

    track_event(user.current_enrollment, :sent_nudge,  nudge_type: :checkin_nudge, mode: :sms, message:message)


  	# send SMS
  	TWILIO_CLIENT.account.sms.messages.create(from: long_code, to: phone, body: message)
  end

  def self.generate_sms_message(type, first_name, url)
    # grab our text message
    text = SMS_TEXT[type].sample + " " + url

    # replace name placeholder
    new_text = text.dup
    new_text.sub!("<c-s-name>", ", #{first_name}")
    new_text.sub!("<s-name>", " #{first_name}")
    new_text.sub!("<name-c-s>", "#{first_name}, ")

    if first_name.blank? || new_text.length > 140
      new_text = text.dup
      new_text.sub!("<c-s-name>", "")
      new_text.sub!("<s-name>", "")
      new_text.sub!("<name-c-s>", "")
    end

    # capitalize first letter
    new_text[0] = new_text[0].capitalize unless new_text.start_with? "app"

    new_text
  end

  SMS_TEXT = {
    sleep: [
      "Good morning<c-s-name>. Please check-in with app and tells us a bit about your sleep.",
      "Top o' the mornin' to you<c-s-name>! app has 4 quick questions about last night.",
      "Rise and shine<c-s-name>!  Please check-in with app and tell us about your slumber.",
      "Good morning<c-s-name>! Tell app about the quality of your Zzz's.",
      "Feeling refreshed this morning? Let app know by answering a few quick questions.",
      "Hey<s-name>! Could you quickly check in with app and answer some questions about your bedtime?",
      "Sorry to bother you, but could you quickly check-in with app and tell us how you've been sleeping?",
      "Psst...! app has a few quick questions about your sleep ready for you.",
      "app wants to know how many sheep you counted last night.",
      "Still a little sleepy? Let app know and we'll fine-tune your plan to revitalize your sleep.",
    ],
    focus: [
      "Good afternoon<c-s-name>. Hope we aren't distracting you, but app has a few quick questions about your ability to stay focused.",
      "app POP QUIZ: Tell us how focused you are right now.",
      "<name-c-s>are you paying attention today? Please check-in with app.",
      "Been daydreaming about the future<c-s-name>? Please let app know.",
      "Do you feel distracted today<c-s-name>? Let app know how you're feeling.",
      "Does it feel like your day is moving without you? Please check-in with app and let us know.",
      "Time to check-in with app and let us know how you're trending in Focus, so we can optimize your program.",
      "Help progress your app program by letting us know more about how your Focus has been.",
      "app wants to know where your head's at today.  Please answer a few quick questions.",
      "Having trouble Focusing? Let app know and we'll update your program to sharpen your attention."
    ],
    positivity: [
      "Good morning<c-s-name>. Please check-in with app and tell us a bit about your mood.",
      "Feeling lucky<c-s-name>? Tell app how your day is going.",
      "app POP QUIZ: How's your mood this week?",
      "Time to check-in with app and let us know how you're trending in Positivity.",
      "app needs a bit more Positivity data from you to prepare important insights and analysis.",
      "Been working out your Positivity muscle?  Report back to app and help evolve your training program.",
      "Are you championing Positive Mental Attitude today?  Check-in with app and let us know, so we can update your program!",
      "app would like to get a few Positivity measures from you to fine-tune your program.",
      "Is it easy for you to smile at things today?  Answer a few quick questions and let app know.",
      "Getting difficult to find the silver linings today? Just let app know, and we'll get you back on the happy track."
    ],
    social: [
      "Good afternoon<c-s-name>. We hope we aren't interrupting, but app has a few quick questions about your friends and family.",
      "app POP QUIZ: Do you feel loved?",
      "Time to check-in with app and let us know how your'e trending in Relationships.",
      "app needs a bit more Relationship data from you to prepare important insights and analysis.",
      "Have you taken time to appreciate your close relationships? Report back to app and let us know.",
      "Help inform your app program by letting us know a bit more about your Relationships.",
      "Can you feel the love? app is curious to know, so please tell us how your relationships have been lately.",
      "Do you need a hug? Let app know and we'll fine-tune your plan to boost the love in your life.",
      "Feeling like you're on a desert island today? Just let app know and we'll get you back on the love boat.",
      "Need some space, or need more company? Let app know and we'll get you back on the track to happiness."
    ]
  }
end
