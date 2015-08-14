class Thank < ActiveRecord::Base
	include UUIDRecord

  COMPONENT_TYPE = "thank"
	VISIONBOARD_ADDITION_COMPONENT_TYPE = "visionboard_thank"

	ADDED_EVENT = "#{COMPONENT_TYPE}_added".to_sym
	VISUALIZED_EVENT = "#{COMPONENT_TYPE}_visualized".to_sym

  attr_accessible :uuid, :image_urls, :text, :color
  serialize :image_urls, Array

  validates :text, presence: true

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
end

