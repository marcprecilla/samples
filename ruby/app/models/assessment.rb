class Assessment < ActiveRecord::Base
  include UUIDRecord
  attr_accessible :enrollment_uuid, :type, :uuid, :baseline_assessment_uuid

  scope :pre_paywall, where(type:"PrePaywallAssessment") # Ref to subclass.  So sue me.
  scope :baseline, where(type:"BaselineAssessment") # Ref to subclass.  So sue me. (Again)
  scope :checkin, where(type:"CheckinAssessment")
  scope :three_sixty, where(type:"ThreeSixtyAssessment") # Ref to subclass.  So sue me. (Yet again)

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
  has_one :baseline_assessment, primary_key: 'uuid', foreign_key: 'baseline_assessment_uuid'
  has_one :user, through: :enrollment
  has_many :responses, primary_key: 'uuid', foreign_key: 'assessment_uuid', dependent: :destroy

end
