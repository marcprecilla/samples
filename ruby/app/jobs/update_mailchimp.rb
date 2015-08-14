class UpdateMailChimp
  @queue = :low

  # state is one of :lead, :user, or :subscriber
  def self.perform(email, state)
    state = state.to_s.titlecase
    Rails.logger.info "Updating #{email}'s MailChimp status to #{state}"

  	merge_vars = {}

  	if user = User.find_by_email(email)
      merge_vars[:fname] = user.first_name if user.first_name.present?
      merge_vars[:lname] = user.last_name if user.last_name.present?
  	
  	elsif lead = Lead.find_by_email(email) # look for lead
			merge_vars[:fname] = lead.name if lead.name.present?
  	end

  	#:lead, :user, :subscriber => "Lead", "User", "Subscriber"
		groupings=[{id:MC_USER_TYPE_GROUP_ID, groups:state}]
  	merge_vars[:groupings]=groupings

    begin
      gb = Gibbon.new(MC_API_KEY)
      ret = gb.list_subscribe(id: MC_STRESS_LESS_LIST_ID, email_address: email, merge_vars: merge_vars, double_optin: false,
        update_existing: true, replace_interests: true, send_welcome: false)

      Rails.logger.info 'MailChimp success'
      
    rescue Gibbon::MailChimpError => e
      Rails.logger.error 'MailChimp error: ' + e.message
    end

  end
end

