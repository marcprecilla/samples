module StripeHelper
	def find_charges(from, to, limit=3)
	  Stripe::Charge.all(count:limit, created:{gte:from.to_i, lte:to.to_i})
	end
	#charges = find_charges(7.days.ago, Time.now)
	def row_for(user, charges)
	
	end
	# charges.each do |charge|
	# cid = charge.customer
end
