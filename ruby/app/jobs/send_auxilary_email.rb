require 'mandrill'

class SendAuxilaryEmail
  include StressLessEmailHelper

  @queue = :normal

  QUOTE_EMAIL_TEMPLATE_SLUG = "app-stressless-quote-of-the-day"
  TEXT_CONTENT_EMAIL_TEMPLATE_SLUG = "app-stressless-text-content"
  VIDEO_CONTENT_EMAIL_TEMPLATE_SLUG = "app-stressless-video-content"


  PROTOCOL = ENV['REQUIRE_HTTPS'] ? 'https' : 'http'
  HOST = ENV['MAIL_HOST'] || 'localhost:3000'
  GA_DOMAINS = (%w(train.myapp.com stresslessapp.myapp.com stressless.myapp.com www.myapp.com) + [ENV['DOMAIN_NAME']]).uniq
  
  # https://sprint.ly/product/10211/#!/item/51
  # Action Plans - Day 1
  # Video Blogs - Day 3 Article or Video 
  # Inspirational Quotes - Day 2 & Day 6
  def self.perform
    Rails.logger.info "SendAuxilaryEmail"

    # Each week, a new action plan is generated, so we need to look only at any one action plan for one week of its life.
    two_days = ActionPlan.subscribed.where(created_at: 3.days.ago..2.days.ago)
    three_days = ActionPlan.subscribed.where(created_at: 4.days.ago..3.days.ago)
    six_days = ActionPlan.subscribed.where(created_at: 7.days.ago..6.days.ago)

    Rails.logger.info "- two_days: #{two_days.count}, three_days: #{three_days.count}, six_days: #{six_days.count}"

    # group each set of action plans into weeks in order to send the correct email for each set.
    two_days_by_week = {}
    two_days.each do |plan|
      two_days_by_week[plan.week] ||= []
      two_days_by_week[plan.week] << plan
    end

    three_days_by_week = {}
    three_days.each do |plan|
      three_days_by_week[plan.week] ||= []
      three_days_by_week[plan.week] << plan
    end

    six_days_by_week = {}
    six_days.each do |plan|
      six_days_by_week[plan.week] ||= []
      six_days_by_week[plan.week] << plan
    end


    two_days_by_week.each { |week, plans| mail_quote_to(plans, 1) }
    six_days_by_week.each { |week, plans| mail_quote_to(plans, 2) }
    
    # three_days_by_week.each do |week, plans|
    #   rand(2) == 0 ? mail_video_to(plans, week) : mail_article_to(plans)
    # end

  end

  # there are two quotes per week, quote index is 0 or 1
  def self.mail_quote_to(action_plans, quote_index)
    action_plans = Array.wrap(action_plans)

    quote = StressLessEmailHelper::quote action_plans.first.week, quote_index
    Rails.logger.warn("No quote content is avilable for week #{action_plans.first.week} and index #{quote_index}") and return nil unless quote

    mail_content = {subject:"app Quote of the Day"}
    merge_content = [
      {name: 'QUOTE_TEXT',   content: quote.first},
      {name: 'QUOTE_SOURCE', content: quote.last},
    ]

    send_email QUOTE_EMAIL_TEMPLATE_SLUG, action_plans, mail_content, merge_content
  end
  def self.mail_article_to(action_plans)
    subject = StressLessEmailHelper::subject action_plans.first.week
    Rails.logger.warn("No subject content is avilable for week #{action_plans.first.week} and index #{quote_index}") and return nil unless subject

    mail_content = {subject:subject}
    merge_content = []
    send_email TEXT_CONTENT_EMAIL_TEMPLATE_SLUG, action_plans, mail_content, merge_content
  end
  def self.mail_video_to(action_plans)
    subject = StressLessEmailHelper::subject action_plans.first.week
    Rails.logger.warn("No subject content is avilable for week #{action_plans.first.week} and index #{quote_index}") and return nil unless subject

    mail_content = {subject:subject}
    merge_content = []
    send_email VIDEO_CONTENT_EMAIL_TEMPLATE_SLUG, action_plans, mail_content, merge_content
  end

  def self.send_email(template_slug, action_plans, mail_content, merge_content)
    action_plans = Array.wrap(action_plans)

    Rails.logger.info merge_content.to_yaml

    recipients = action_plans.collect do |plan|
      u= plan.enrollment.user
      u=User.find_by_uuid(u.uuid) if u.email.nil?
      u
    end

    m = Mandrill::API.new
    message = {
      subject: mail_content[:subject],
      from_email: 'no-reply@myapp.com',
      from_name: 'app Team',
      to: recipients.collect  { |u| {email: u.email, name: u.name}},
      track_opens: true,
      track_clicks: true,
      url_strip_qs: true,
      preserve_recipients: false,
      global_merge_vars: merge_content,
      merge_vars: recipients.collect {|user| { rcpt: user.email,
        vars:[
          {name: 'EMAIL', content: user.email}, 
          {name: 'PROFILE_URL', content: user.profile_image_url},
          {name: 'UNSUBSCRIBE', content: self.unsubscribe_url(user)}
        ]}},
      google_analytics_domains: GA_DOMAINS,
      google_analytics_campaign: template_slug
    }

    results = m.messages.send_template(template_slug, [], message)
    Rails.logger.info "Mandrill results: #{results.inspect}"
  end

  def self.start_url
    Rails.application.routes.url_helpers.dashboard_url(protocol: PROTOCOL, host: HOST)
  end

  def self.unsubscribe_url(user)
    Rails.application.routes.url_helpers.unsubscribe_url(protocol: PROTOCOL, host: HOST, email: user.email)
  end

  def self.intervention_image_url(key)
    key = key.to_s.gsub("_","-")
    "http://s3.myapp.com/stressless/email/email.stressless.int.#{key}.gif"
  end

end
