class Event < ActiveRecord::Base
  include UUIDRecord

	scope :of_type, ->(type)  { where(type:type) }
  scope :with_points, where('points is not null')
  scope :since, ->(time) {where(created_at:[time..Time.now]) }
  scope :between, ->(range) {where(created_at:range) }
  scope :except_mixpanel, where('type not like "mix_panel%"')

  # can use a single week number or a range
  scope :for_week, ->(week) { joins(action_item:[:action_plan]).where(action_plans:{week:week}) }
  scope :for_week_and_day, ->(week,day) { joins(action_item:[:action_plan]).where(action_plans:{week:week}).where(action_items:{day:day}) }


  scope :new_session, where(type: :new_session)
  scope :checkins, where(type: :checkin)
  scope :completed_intervention, where(type:[:completed_assigned_intervention, :completed_extra_credit_intervention])
  scope :vision_board_activities, where(type: [Intention::ADDED_EVENT, Intention::VISUALIZED_EVENT, Thank::ADDED_EVENT, Thank::VISUALIZED_EVENT, ])

  # FIXME: Lead doesn't have a uuid, need a migration to use id
  attr_accessible :data, :type, :enrollment, :enrollment_uuid, :lead, :lead_uuid, :created_at, :updated_at, :target_type, :target_uuid, :points, :action_item, :action_item_uuid
  self.inheritance_column = :_type_disabled

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
  belongs_to :action_item, primary_key: 'uuid', foreign_key: 'action_item_uuid'
  has_one :user, through: :enrollment

 	serialize :data, Hash

  delegate :week, to: :action_item, allow_nil:true
  delegate :day, to: :action_item, allow_nil:true
  delegate :sequential_day, to: :action_item, allow_nil:true
  delegate :sequential_date, to: :action_item, allow_nil:true

 	def target=(target)
 		target_type = target.class.to_s
 		target_uuid = target.uuid
 	end

 	def target
 		clazz = eval target_type
 		clazz.find_by_uuid(target_uuid)
 	rescue
 		puts "Dev error: target_type is invalid: #{target_type}"
 	end

end
