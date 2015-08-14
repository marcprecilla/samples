module SubscriptionsHelper
	def update_subscription_button(text='Update Subscription')
		link_to text, new_subscription_path, class: 'btn btn-border btn-block'
	end

	def cancel_subscription_button(text='Cancel Subscription')
		link_to text, subscription_path, method: :delete,
			confirm: "Are you sure you want to cancel your subscription?", class: 'btn btn-border btn-block'
	end
end
