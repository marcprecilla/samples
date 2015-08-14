class Step < ActiveRecord::Base
  include UUIDRecord

  COMPONENT_TYPES = [:pam, :check, :intervention]

  attr_accessible :component_type, :component_uuid, :part_order, :part_uuid, :uuid, :why_text, :why_source

  belongs_to :part, primary_key: 'uuid', foreign_key: 'part_uuid'

  validates :part_uuid, presence: true
  validates :component_type, inclusion: {in: COMPONENT_TYPES, allow_nil: true}

  after_initialize :set_defaults

  # todo: guarantee part_order is correct

  def set_defaults
    self.why_text ||= ""
    self.why_source ||= ""
  end

  def intervention
  	Intervention.find_by_uuid component_uuid
  end
  
  def check
  	Check.find_by_uuid component_uuid
  end
end
