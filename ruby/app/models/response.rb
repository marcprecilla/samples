class Response < ActiveRecord::Base
  include UUIDRecord
  
  scope :for_enrollment, ->(enrollment)  { joins(:assessment).where(assessments: {enrollment_uuid:enrollment.uuid}) }
  scope :for_check_category, ->(category) { joins(:check).where(checks: {category:category}) }

  attr_accessible :check_uuid, :activity_uuid, :uuid, :value, :assessment_uuid, :respondent_identifier

  belongs_to :check, primary_key: 'uuid', foreign_key: 'check_uuid'
  belongs_to :assessment, primary_key: 'uuid', foreign_key: 'assessment_uuid'


  validates :check_uuid, presence: true
  validates :assessment_uuid, presence: true
  validates :value, inclusion: {in: lambda {|r| r.check.min_response_value..r.check.max_response_value}, unless: lambda {|r| r.check.nil?}}

  COPING_ASSESSMENT_SCORES = [0.55,1.1,1.65,2.2]

  def enrollment
    assessment.try(:enrollment_uuid)
  end

  # 1-100
  def adjusted_normal_score
    max = check.max_response_value
    min = check.min_response_value

    # assumes a step value of '1'
    s = 100.0*(value-1)/(max-min)
    s = 100 - s if check.inverse_scoring
    s
  end
end
