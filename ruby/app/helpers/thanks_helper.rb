module ThanksHelper

	def some_sample_thanks(count, user=nil)
		raise "unsupported" if count > 10
		thanks = []
		while thanks.count < count
			thanks << sample_thank(user)
			thanks.uniq!
		end
		thanks.shuffle
	end

	def sample_thank(user=nil)
		cs = nil
		if user && rand(10)==0
			cs = context_specific_thank(user)
		end

		cs || context_free_thank
	end


	CONTEXT_FREE_THANKS = [
			"my loving family",
			"my great friends",
			"my creativity",
			"my good health",
			"my good fortune",
			"my home",
			"my great style",
			"funny people",
			"the planet",
			"my life",
			"my childhood",
			"a great career",
			"good genes",
			"my education",
			"my love life",
			"delicious food",
			"technology",
		]
		def context_free_thank; CONTEXT_FREE_THANKS.sample; end

		def context_specific_thank(user)
			options = []
			options << :parent if user.parent?
			options << :partner if user.married? || user.in_a_relationship?

p options

			case options.sample
			when :parent
				"my children"
			when :partner
				"my loving partner"
			end
		end
end