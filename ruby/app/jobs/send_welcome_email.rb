require 'mandrill'
include StressLessEmailHelper

class SendWelcomeEmail
  @queue = :normal
  
  def self.perform(name, email)
    puts "SendWelcomeEmail for #{name}, #{email}"
    send_welcome_email(name, email)
  end

  def self.send_welcome_email(name, email)
    subject = "Getting Started with app"

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
            {name: 'FNAME', content: name.try(:upcase)},
            {name: 'SUBJECT', content: subject},
            {name: 'START', content: self.start_url},
          ],
          merge_vars: [
          {
            rcpt: email,
            vars:[
              {name: 'EMAIL', content: email}, 
              {name: 'UNSUBSCRIBE', content: self.unsubscribe_url(email)}
            ]
          }],
          google_analytics_domains: GA_DOMAINS,
          google_analytics_campaign: "sl_welcome_email"
    }

    mandrill_template = 'stressless-welcome-email'
    results = m.messages.send_template(mandrill_template, [], message)
    puts "Mandrill results: #{results.inspect}"
  end

  def self.start_url
    Rails.application.routes.url_helpers.dashboard_url(protocol: PROTOCOL, host: HOST)
  end

  def self.unsubscribe_url(email)
    Rails.application.routes.url_helpers.unsubscribe_url(protocol: PROTOCOL, host: HOST, email: email)
  end

end
