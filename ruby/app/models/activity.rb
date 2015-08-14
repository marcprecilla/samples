class Activity < ActiveRecord::Base
  include UUIDRecord
  include PointsHelper
  
  scope :interventions, joins(:action_item).where("action_items.component_type LIKE 'intervention'")
  scope :checks, joins(:action_item).where("action_items.component_type LIKE 'check'")

  attr_accessible :description, :name, :uuid, :enrollment, :enrollment_uuid, :intervention, :intervention_uuid, :day,
      :text, :image_urls, :boost, :action_item

  # has_many :responses, primary_key: 'uuid', foreign_key: 'activity_uuid', dependent: :destroy

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
  belongs_to :action_item, primary_key: 'uuid', foreign_key: 'action_item_uuid'
  belongs_to :intervention, primary_key: 'uuid', foreign_key: 'intervention_uuid'

  validates :enrollment_uuid, presence: true
  # validates :intervention_uuid, presence: true

  serialize :image_urls, Array

  delegate :points, to: :action_item, allow_nil:true
  delegate :prescribed?, to: :action_item, allow_nil:true

  def points
    action_item ? action_item.points : STARTED_EXTRA_CREDIT_INTERVENTION_POINTS
  end
end
