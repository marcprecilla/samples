class SendAffirmationNudge
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
    message = generate_sms_message(user.first_name)

    track_event(user.current_enrollment, :sent_nudge,  nudge_type: :affirmation_nudge, mode: :sms, message:message)

    # send SMS
    TWILIO_CLIENT.account.sms.messages.create(from: long_code, to: phone, body: message)
  end

  def self.generate_sms_message(first_name)
    # grab our text message
    text = SMS_TEXT.sample

    dashboard_url = Api::Bitly.shorten(Rails.application.routes.url_helpers.dashboard_url(protocol: PROTOCOL, host: HOST))
    visionboard_url = Api::Bitly.shorten(Rails.application.routes.url_helpers.visionboard_url(protocol: PROTOCOL, host: HOST))


    # replace name placeholder
    new_text = text.dup
    new_text.sub!("<first_name>", ", #{first_name}")
    new_text.sub!("<c_s_first_name>", ", #{first_name}")
    new_text.sub!("<train_link>", dashboard_url)
    new_text.sub!("<vision_board_link>", visionboard_url)

    if first_name.blank? || new_text.length > 140
      new_text = text.dup # reset
      new_text.sub!("<first_name>", "")
      new_text.sub!("<c_s_first_name>", "")
      new_text.sub!("<train_link>", "")
      new_text.sub!("<vision_board_link>", "")
    end

    # capitalize first letter
    new_text[0] = new_text[0].capitalize unless new_text.start_with? "app"
    new_text
  end



  SMS_TEXT = [
"\"You are the universe, expressing itself as a human for a little while.\" -Eckhart Tolle via app <train_link>",
"No one has more control over your life's journey than you do. -app <train_link>",
"Love does not understand time or distance. The love of your friends and family is always with you, no matter where you are. -app <train_link>",
"Take a moment to enjoy your successes. The only person you're in competition with is yourself. -app <train_link>",
"Within the next hour, take a few minutes to think of 3 things you are grateful for. -app <train_link> ",
"Wake up each day with a specific intention. Do not let the day end without taking steps toward that intention. -app <train_link>",
"Failure is ripe with the opportunity to learn. -app <train_link>",
"You are a book that is still being written. Don't worry about how it ends. Focus on the next page. -app <train_link>",
"You are a child of the universe. And your life is magnificent. -app <train_link>",
"What is your intention for the day<c_s_first_name>? -app <vision_board_link>",
"What is your intention for the week<c_s_first_name>? -app <vision_board_link>",
"What is your intention for the month<c_s_first_name>? -app <vision_board_link>",
"What is your intention for the year<c_s_first_name>? -app <vision_board_link>",
"What is your intention for your physical health<c_s_first_name>? -app <vision_board_link>",
"What is your intention for your mental health<c_s_first_name>? -app <vision_board_link>",
"What is your intention for your work life<c_s_first_name>? -app <vision_board_link>",
"What is your intention for your romantic life<c_s_first_name> app <vision_board_link>",
"What is your intention for your family life<c_s_first_name>? -app <vision_board_link>",
"Give a genuine compliment to someone you don't often speak to. -app <train_link>",
"If you find yourself complaining today, think of 3 things you're grateful for to replace each complaint. -app <train_link>",
"Stop and take 7 deep breaths somewhere quiet within the next 30 minutes. -app <train_link>",
"<first_name>, tell someone you love how much you appreciate having them in your life today. -app <train_link>",
"If you can do it safely<c_s_first_name>, go for a slow stroll around the block at work or at home. -app <train_link>",
"Close your eyes<c_s_first_name>, and visualize where you want to be 30 days from now. -app <vision_board_link>",
"Close your eyes and enjoy the memories you've made with someone you truly love. -app <train_link>",
"Reach out to someone you know is stressed and offer them advice on how to relax. -app <train_link>",
"So far, there is nothing the world has thrown at you that you haven't survived. You are a survivor. -app <train_link>",
"Don't ever forget the importance of quality sleep. Try to wind down a little early tonight. -app <train_link>",
"If you need it<c_s_first_name>, do not be afraid to ask for guidance. -app <train_link>",
"Be aware of all the little deeds that have been done on your behalf. -app <train_link>",
"The only thing separating your dreams from your reality is the action you have yet to take. -app <train_link>",
"Are you happy today<c_s_first_name>? -app <train_link>",
"What are 3 small things you could do today to improve your day? -app <train_link>",
"You have the power to leave any situation that makes you uncomfortable. -app <train_link>",
"You have the power to influence the world around you if you choose to. -app <train_link>",
"Your thoughts are your reality. And your thoughts are your choice. -app <train_link>",
"Let go of fear and negative thoughts that do nothing but drain your energy. -app <train_link>",
"Survival is not enough. Follow your dreams as gratitude for the life you have been given. -app <train_link>",
"You can set yourself free from any situation. -app <train_link>",
"The past has no power over you, but you have complete control over your future. -app <train_link>",
"You are a gift to the world, your community, your family & your friends. -app <train_link>",
"Ask someone you love to help support your dreams. -app <train_link>",
"Rejection is not a reflection of you, but of circumstances. -app <train_link>",
"Frequently ask yourself \"How did I get here?\" and \"Where am I going next?\". -app <train_link>",
"Do not let your life be ruled by circumstances. Your dreams and desires are worthy of pursuit. -app <train_link>",
"Take time this week to show your friends and family that you love them. -app <train_link>",
"Forgive yourself & love yourself. If you don't, then no one else can either. -app <train_link>",
"It's okay to be nervous, but do not let your anxiety rob you of enriching experiences. -app <train_link>",
"Follow your intentions and your intuitions. Don't be distracted by fear. -app <train_link>",
"Fall in love with yourself before falling in love with anything or anyone else. -app <train_link>",
"Do no pass your stress onto someone else. Calm down. Breath deeply. Move forward. -app <train_link>",
"Take a moment to pause and relax within the next hour. Nothing is more important than your health and your sanity. -app <train_link>",
"Feel like screaming? Then scream. (In a private area, and not at another person.) -app",
"Sometimes standing in the sun can be a quick remedy for a stressful day. -app <train_link>",
"Make a new playlist of your favorite music if you have some spare time today. -app <train_link>",
"Apologize to someone you may have hurt or offended. -app <train_link>",
"Think about your stressors and evaluate whether or not they are worth your health & happiness. -app <train_link>",
"Look up into the night sky and marvel at the infinite. -app <train_link>",
"Calm yourself & quiet your mind. This is a moment for you to connect with your intentions. -app <vision_board_link>",
"Do not start any new projects until you are happy with the progress of your existing ones. -app <train_link>",
]
end
# SendAffirmationNudge.perform(User.first.uuid)
