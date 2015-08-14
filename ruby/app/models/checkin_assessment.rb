class CheckinAssessment < Assessment
	FOCUS_SUBCATEGORIES = [:focus_1, :focus_2, :focus_3, :focus_4]
	POSITIVITY_SUBCATEGORIES = [:positivity_1, :positivity_2, :positivity_3, :positivity_4]
	SLEEP_SUBCATEGORIES = [:sleep_1, :sleep_2, :sleep_3, :sleep_4]
	SOCIAL_SUBCATEGORIES = [:social_1, :social_2, :social_3, :social_4]

	SUBCATEGORIES = {
		focus:FOCUS_SUBCATEGORIES,
		positivity:POSITIVITY_SUBCATEGORIES,
		sleep:SLEEP_SUBCATEGORIES,
		social:SOCIAL_SUBCATEGORIES,  	
	}

	# the checkin assessment is complete if there are responses for all the questions
	def complete?
		# responses.pluck(:check_uuid).uniq.size >= check_uuids.count
		puts "CheckinAssessment(#{id}).complete?  #{responses.count}"
		responses.count >= 16  # the check may need to be stronger than this (checking that each category exists)
	end

  def completed_at
    return nil unless complete?
    responses.last.created_at
  end

	# The score for each variable is the sum of individual item/question scores divided 
	# by the number of questions (i.e. the arithmetic average).
	def score
		{
			focus: value_for(:focus),
			positivity: value_for(:positivity),
			sleep: value_for(:sleep),
			social: value_for(:social),
		}
	end

	# :sleep -> [:sleep_1, :sleep_2, :sleep_3, :sleep_4]
	def subcategories_for_category(category)
		case category
		when :focus; FOCUS_SUBCATEGORIES
		when :positivity; POSITIVITY_SUBCATEGORIES
		when :sleep; SLEEP_SUBCATEGORIES
		when :social; SOCIAL_SUBCATEGORIES
		end
	end

	private

	def value_for(category)
		# return rand(20)+1 
		rs= responses_for_category(category).collect(&:adjusted_normal_score)
		rs.compact.average
	end

	def responses_for_category(category)
		responses_for_subcategories(subcategories_for_category(category))
	end
	def responses_for_subcategories(categories)
		responses.where(check_uuid:check_uuids_for_categories(categories))
	end

	def check_uuids
		Check.checkin.pluck(:uuid).uniq
	end
	def check_uuids_for_categories(categories)
		Check.checkin.where(category:categories).pluck(:uuid).uniq
	end

end
