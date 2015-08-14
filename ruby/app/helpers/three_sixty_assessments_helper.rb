module ThreeSixtyAssessmentsHelper
	def process_substitutions(text, subject_user)
		name = subject_user.first_name

		gender = subject_user.gender
		if gender.nil?
			his_her = "his/her"
			he_she = "he/she"
		elsif gender == 'male'
			his_her = "his"
			he_she = "he"
		else
			his_her = "her"
			he_she = "she"
		end
		
		text.gsub('%NAME%',name).gsub('%HIS_HER%',his_her).gsub('%HE_SHE%',he_she)
	end

	def prepare_three_sixty_assessment_attributes(enrollment)
    return unless three_sixty_assessment = enrollment.assessments.three_sixty.last
    return unless three_sixty_assessment.complete?

    assessment_results = three_sixty_assessment.try(:results)
   return unless assessment_results

    @three_sixty_levels = {
    	focus:score_level_for_focus(assessment_results[:focus]),
    	positivity:score_level_for_focus(assessment_results[:positivity]),
    	sleep:score_level_for_focus(assessment_results[:sleep]),
    	social:score_level_for_focus(assessment_results[:social]),
    }

    # @focus_level = score_level_for_focus(assessment_results[:focus])
    # @positivity_level = score_level_for_positivity(assessment_results[:positivity])
    # @sleep_level = score_level_for_sleep(assessment_results[:sleep])
    # @social_level = score_level_for_social(assessment_results[:social])
	end


end
