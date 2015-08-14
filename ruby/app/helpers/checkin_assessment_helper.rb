module CheckinAssessmentHelper
	def checkin_score_for(benefits_hash)
		res = {}
		BENEFITS_QUESTIONS.keys.each do |category|
			benefits = benefits_hash[category.to_s] || benefits_hash[category.to_sym]
			count_of_benefits = benefits ? benefits.count : 0
			res[category] = MAX_NUMBER_OF_BENEFITS - count_of_benefits
		end
		res
	end
end
