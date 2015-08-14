module IntentionsHelper

	def self.strip_duplicate_images(image_urls)
		before = image_urls.clone
		# after = image_urls.uniq {|i| i =~ /\/([^\/]*?)(.png|.jpg|.jpeg|.gif)/; $1}.compact  # remove duplicates, including dupes of differing image types (no pref for the type)
		after = image_urls.uniq {|i| i =~ /\/(.*?)(.png|.jpg|.jpeg|.gif)/; $1}.compact  # remove duplicates, including dupes of differing image types (no pref for the type)
			
		log "STRIP_DUPLICATE_IMAGES: (#{before.length}->#{after.length}) [#{before.join(' | ')}] -> [#{after.join(' | ')}]" if before.length != after.length
		after
	end

	def some_sample_intentions(count, user=nil)
		raise "unsupported" if count > 10
		intentions = []
		while intentions.count < count
			intentions << sample_intention(user)
			intentions.uniq!
		end
		intentions.shuffle
	end

	def sample_intention(user=nil)
		cs = nil
		if user && rand(10)==0
			cs = context_specific_intention(user)
		end

		cs || context_free_intention
	end


	CONTEXT_FREE_INTENTIONS = [
			"strong & healthy",
			"a better friend",
			"more romantic",
			"brilliant",
			"prosperous",
			"meaningful",
			"more confident",
			"very wealthy",
			"exciting to others",
			"a role model",
			"important",
			"more loving",
			"happy",
			"always smiling",
		]
		def context_free_intention; CONTEXT_FREE_INTENTIONS.sample; end


# a better father	"Gender is not ""Male""


# a better husband	"Gender is not ""Male"" and is not ""Married""
# a better boyfriend	"Gender is not ""Male"" and is not ""In a Relationship""
# a better wife	"Gender is not ""Female"" and is not ""Married""
# a better girlfriend	"Gender is not ""Female"" and is not ""In a Relationship""
# more romantic	"Relationship status is not ""Married"" or ""In a Relationship""
		def context_specific_intention(user)
			options = []
			options << :parent if user.parent?
			options << :married if user.married?
			options << :relationship if user.in_a_relationship?
			options << :romantic if user.single?

			case options.sample
			when :parent
				user.male? ? "a better father" : "a better mother"
			when :married
				user.male? ? "a better husband" : "a better wife"
			when :relationship
				user.male? ? "a better boyfriend" : "a better girlfriend"
			when :single
				"more romantic"
			end
		end
end

