class PrePaywallAssessment < Assessment
  include BigFiveAssessmentHelper
  include BenefitAssessmentHelper

  attr_accessible :benefits_hash
  serialize :benefits_hash, Hash

  def include_personality?
  	(!results.nil?) && results.count > 0
  end

  def benefits_score
  	benefits_score_from_benefits_hash(benefits_hash)
  end
end
