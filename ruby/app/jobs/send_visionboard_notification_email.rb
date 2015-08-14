require 'mandrill'
include VisionboardHelper

class SendVisionboardNotificationEmail
  @queue = :normal


  # kind: intention, thank, intention_image, thank_image
  def self.perform(plan_uuid, kind)
    Rails.logger.info "SendVisionboardNotificationEmail(#{kind}) for plan #{plan_uuid}"
    action_plan = StressLessAppWeeklyActionPlan.find_by_uuid(plan_uuid)
    enrollment = action_plan.enrollment
    user = enrollment.user

    email = user.email
    name = user.first_name

    template = "visionboard-item-available-nudge"
    subject = ""
    message = ""
    call_to_action_url = ""
    
    case kind.to_s
    when Intention::COMPONENT_TYPE 
      subject = "Time for an intention"
      message = "message for new intention"
      call_to_action_url = new_intention_url
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      target = enrollment.intentions.last
      subject = "Visualize your intention"
      message = "message for new intention visualization"
      call_to_action_url = intention_url(target)
    when Thank::COMPONENT_TYPE
      subject = "Time to thank someone"
      message = "message for new thank"
      call_to_action_url = new_thank_url
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      target = enrollment.thanks.last
      subject = "Visualize your gratitude"
      message = "message for new intention visualization"
      call_to_action_url = thank_url(target)
    end

    m = Mandrill::API.new
    message = {
      subject: subject,
      from_email: 'no-reply@myapp.com',
      from_name: 'app Team',
      to:  [{email: email, name: name}],
      track_opens: true,
      track_clicks: true,
      url_strip_qs: true,
      preserve_recipients: false,
      global_merge_vars: [
        {name: 'FNAME', content: user.first_name},
        {name: 'LNAME', content: user.last_name},
        {name: 'CALL_TO_ACTION', content: call_to_action_url},
        {name: 'MESSAGE', content: message}
      ],
      merge_vars: [action_plan].collect {|ap| {rcpt: email,
        vars:[
          {name: 'PROFILE_URL', content: user.profile_image_url},
          {name: 'EMAIL', content: email}, 
          {name: 'UNSUBSCRIBE', content: self.unsubscribe_url(user.email)}]}},
      google_analytics_domains: GA_DOMAINS,
      google_analytics_campaign: "sl_intention_available"
    }
    Rails.logger.info "SendIntentionNotificationEmail.before send with #{message.to_yaml}"

    results = m.messages.send_template(template, [], message)
    Rails.logger.info "Mandrill results: #{results.inspect}"
  end

  def self.unsubscribe_url(email)
    Rails.application.routes.url_helpers.unsubscribe_url(protocol: PROTOCOL, host: HOST, email: email)
  end

  def self.new_intention_url; Rails.application.routes.url_helpers.new_intention_url(protocol: PROTOCOL, host: HOST); end
  def self.new_thank_url; Rails.application.routes.url_helpers.new_thank_url(protocol: PROTOCOL, host: HOST); end

  def self.intention_url(intention); Rails.application.routes.url_helpers.intention_url(id:intention.uuid, protocol: PROTOCOL, host: HOST); end
  def self.thank_url(thank); Rails.application.routes.url_helpers.thank_url(id:thank.uuid, protocol: PROTOCOL, host: HOST); end

end
