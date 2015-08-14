class HappyFaceInterventionScore < ActiveRecord::Base
  include UUIDRecord

  COMPONENT_TYPE = "happy_face"

  attr_accessible :uuid, :enrollment_uuid, :enrollment, :action_item_uuid, :action_item, :completed, :duration, :score

  scope :completed, where(completed: true)

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
end
