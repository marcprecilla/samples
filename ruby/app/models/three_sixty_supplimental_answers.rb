# this class contains supplmental answer information that is provided by a specific respondent
#   The respondant's normal answers should ideally be here as well, but that would break the current 
#   overall structure for the assessments

class ThreeSixtySupplimentalAnswers < ActiveRecord::Base
  include UUIDRecord
  attr_accessible :uuid, :assessment_uuid, :respondent_identifier, :good_times, :ways_to_communicate
  
  belongs_to :assessment, class_name: 'ThreeSixtyAssessment', primary_key: 'assessment_uuid', foreign_key: 'uuid'

  scope :for_recipient, ->(respondent_identifier)  { where(respondent_identifier:respondent_identifier) }

  validates :assessment_uuid, presence: true
  validates :respondent_identifier, presence: true
end
