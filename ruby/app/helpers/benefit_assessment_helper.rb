module BenefitAssessmentHelper

	BENEFITS_QUESTIONS = {
		focus: { 
			question: "I'd like to be more focused so that I can...",
			responses: ["feel real and alive in the present moment","make better decisions in a time crunch","concentrate for longer periods of time","not allow the future or past to consume my thoughts"],
			icons: %w{bullseye stopwatch headcheck  calendar} },
		positivity: {
			question: "I'd like to be more positive so that I can...",
			responses: ["feel good about my life and goals","take time to savor things I love","be less critical of other people", "turn problems into progress & productivity"],
			icons: %w{trophy heart handpoint road} },
		sleep: {
			question: "I'd like to improve sleep so that I can...",
			responses: ["fall asleep with ease", "sleep soundlessly without waking up", "feel more alert during the day", "wake up feeling refreshed"],
			icons: %w{sleep eyelashes sunshine  alarm} },
		social: {
			question: "I'd like to be more social so that I can...",
			responses: ["feel comfortable in my own skin", "foster meaningful relationships", "rekindle old friendships or romances", "be a better friend and relative"],
			icons: %w{footprints relationship  fire award} },
	}


	MAX_NUMBER_OF_BENEFITS = 4
	# def benefits_score_for(enrollment)
	# 	res = {}
	# 	[:focus, :positivity, :sleep, :social].each do |category|
	# 		count_of_benefits = enrollment.benefits.where(category:category).count
	# 		res[category] = MAX_NUMBER_OF_BENEFITS - count_of_benefits
	# 	end
	# 	res
	# end
	def benefits_score_from_benefits_hash(benefits_hash)
		res = {}
		BENEFITS_QUESTIONS.keys.each do |category|
			benefits = benefits_hash[category.to_s] || benefits_hash[category.to_sym]
			count_of_benefits = benefits ? benefits.count : 0
			res[category] = MAX_NUMBER_OF_BENEFITS - count_of_benefits
		end
		res
	end

	def percent_for_value(value)
		value * 18 + 15
	end

	def title_for_benefit(benefit)
		return "Social Skills" if benefit.to_sym == :social
		benefit.to_s.titlecase
	end

	# benefits_hash must be of the form:
	# {
	#	"focus"=>["feel real and alive in the present moment", "make better decisions in a time crunch", "concentrate for longer periods of time", "not allow the future or past to consume my thoughts"], 
	#	"positivity"=>["feel good about my life and goals", "turn problems into progress & productivity"], 
	#	"sleep"=>["feel more alert during the day", "wake up feeling refreshed"]
	# }
	# def add_benefits_to_enrollment(enrollment, benefits_hash)
	# 	logger.info "add_benefits_to_enrollment"
	# 	# remove any preexisting benefits
	# 	enrollment.benefits.destroy_all

	# 	for category in [:focus, :positivity, :sleep, :social]
	# 		benefits = benefits_hash[category] || []
	# 		for benefit in benefits
	# 			logger.info " - adding #{category}/#{benefit}"
	# 			enrollment.benefits.create(name:benefit, category:category)
	# 		end
	# 	end
	# end

end
