require 'mandrill'

class SendThreeSixtyEmail
	@queue = :normal

	def self.perform(invitation_uuid)
		return unless invitation = Invitation.find_by_uuid(invitation_uuid)

		sender = invitation.sender
		subject = "#{sender.name} needs your opinion on something."
		profile_url = sender.profile_image_url
		profile_url ||= 'https://train.myapp.com/assets/' + (sender.female? ? 'female_avatar.png' : 'male_avatar.png')
		url = Rails.application.routes.url_helpers.invitation_url(invitation, protocol: PROTOCOL, host: HOST)
    template = "360-invite"

		# build email
    m = Mandrill::API.new
		message = {
			subject: subject,
			from_name: "app Team",
			from_email: "support@myapp.com",
			to: [{name: invitation.recipient_name, email: invitation.recipient}],
      track_opens: true,
      track_clicks: true,
      url_strip_qs: true,
      preserve_recipients: false,
      global_merge_vars: [
        {name: 'FNAME', content: invitation.recipient_name},
        {name: 'FRIEND', content: sender.first_name},
        {name: 'PROFILE_URL', content: profile_url},
        {name: 'URL', content: url}
      ],
      google_analytics_domains: GA_DOMAINS,
      google_analytics_campaign: "360-invite"
		}

		# send email
		results = m.messages.send_template(template, [], message)
    Rails.logger.info "Mandrill results: #{results.inspect}"

		# update invitation
		# TODO: check sending status
		invitation.update_attribute(:sent_at, Time.now)
	end
end
