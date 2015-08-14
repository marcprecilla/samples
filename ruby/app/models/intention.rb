class Intention < ActiveRecord::Base
	include UUIDRecord

  COMPONENT_TYPE = "intention"
  VISIONBOARD_ADDITION_COMPONENT_TYPE = "visionboard_intention"

	ADDED_EVENT = "#{COMPONENT_TYPE}_added".to_sym
	VISUALIZED_EVENT = "#{COMPONENT_TYPE}_visualized".to_sym

  attr_accessible :uuid, :image_urls, :text, :color
  serialize :image_urls, Array

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
  has_many :action_items, foreign_key: :component_uuid

  validates :text, presence: true

  def action_item
  	action_items.first
  end
end
