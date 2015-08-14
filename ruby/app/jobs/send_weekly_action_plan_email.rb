require 'mandrill'

class SendWeeklyActionPlanEmail
  @queue = :normal

	def self.perform(user_uuid, type)
		return unless user = User.find_by_uuid(user_uuid)

		unsubscribe_url = Rails.application.routes.url_helpers.unsubscribe_url(protocol: PROTOCOL, host: HOST, email: user.email)

		mandrill = Mandrill::API.new
		message = {
			to:[{email: user.email, name: user.name}],
      track_opens: true,
      track_clicks: true,
      url_strip_qs: true,
      preserve_recipients: false,
      global_merge_vars: [
      	{name: 'HOST', content: "#{PROTOCOL}://#{HOST}"},
        {name: 'EMAIL', content: user.email}, 
        {name: 'FNAME', content: user.first_name},
        {name: 'UNSUBSCRIBE', content: unsubscribe_url},

        {name: 'SOURCE', content: user.source},
        {name: 'CAMPAIGN', content: user.campaign},
        {name: 'LANDING_PAGE', content: user.landing_page},
      ],
      google_analytics_domains: GA_DOMAINS,
      google_analytics_campaign: "weekly_ap_#{type.to_s}"
		}

		Rails.logger.info "Sending #{type.to_s} week action plan email to #{user.email}"
		results = mandrill.messages.send_template("#{type.to_s}_week", [], message)
    Rails.logger.info "Mandrill results: #{results.inspect}"
	end
end
