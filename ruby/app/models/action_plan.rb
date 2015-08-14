class ActionPlan < ActiveRecord::Base
  include UUIDRecord
  
  scope :subscribed, joins(:enrollment => :user).where("users.subscription_plan_uuid IS NOT NULL")
  scope :for_week, ->(week)  { where(week:week) }

  attr_accessible :enrollment, :enrollment_uuid, :program, :program_uuid, :uuid, :week, :theme

  belongs_to :enrollment, primary_key: 'uuid', foreign_key: 'enrollment_uuid'
  has_many :action_items, primary_key: 'uuid', foreign_key: 'action_plan_uuid', dependent: :destroy

  validates :enrollment_uuid, presence: true
  validates :program_uuid, presence: true
  validates :week, presence: true

  # each day in the program had a "sequential day" which is simply the 
  # accumulated day of program activity (not calendar day), so:
  #  week 2, day 3 is 10, or seven days for week one plus three days
  #  week 3, day 1 is 14 + 1, or day 15.
  def self.sequential_day_for(week,day)
    # raise "invalid week (#{week})" unless week>0
    raise "invalid day (#{day})" unless (1..7).include?(day)
    (week-1)*7 + day
  end

  # if the action items were all completed as soon as they become available, 
  # then this would be the first day that the activity could be performed.  
  # It is relative to the enrollment's creation date.
  #
  # given that the action plan is created on Jan 1
  #  week 1, day 1 is Jan 1
  #  week 2, day 1 is Jan 8
  def self.sequential_date_for(enrollment, week, day)
    # raise "invalid week (#{week})" unless week>0
    raise "invalid day (#{day})" unless (1..7).include?(day)
    sequential_day = sequential_day_for(week,day)
    enrollment.created_at + (sequential_day-1).days
  end

  # find the action plan previous to this action plan
  def previous_action_plan
    index_for_me = enrollment.action_plans.index(self)
    return nil if index_for_me == 0 # first, no other action item
    enrollment.action_plans[index_for_me-1]
  end

  def incomplete_action_items(day=nil)
    action_items_by_completion(false, day)
  end

  def completed_action_items(day=nil)
    action_items_by_completion(true, day)
  end

  # has the user done any of today's AIs?
  def started_day?(day)
    !completed_action_items(day).empty?
  end

  def complete?
    #incomplete_action_items.empty?
    raise "defined in subclass"
  end
  # def completed_at
  #   complete? ? action_items.last.try(:updated_at) : nil
  # end

  def sequential_day
    ActionPlan.sequential_day_for(week,day)
  end

  def sequential_date
    ActionPlan.sequential_date_for(enrollment,week,day)
  end

  # day is relative to the action plan, not a calendar day.  It is 
  # always in 1..7
  def day
    ai = incomplete_action_items.min_by(&:day)
    ai ? ai.day : 7
  end
  def day_completed_at(day)
    return nil unless 0 < day && day <=7
    action_items.for_day(day).select {|ai| ai.completed_at}.compact.sort.last.try(:completed_at)
  end
  def started_current_day?
    started_day?(day)
  end

  def skip_day(day)
    for item in action_items.for_day(day)
      item.skip! unless item.performed?
    end
  end

  # helper method for testing
  def skip_week
    for item in action_items
      item.skip! unless item.complete?
    end

  end

  def points
    # action_items.to_a.sum { |e| e.points }.to_i
    # enrollment.points_since(created_at)
    #action_items.sum(&:points).to_i
    enrollment.points_since(created_at)
  end

  def points_for_day(action_item)
    # given action_plan and day, find:
    #   the earliest and latest completed times (plus a buffer?)

    plan = action_item.action_plan
    day = action_item.day

    time_range = plan.activity_time_range(day)
    enrollment.points_between(time_range)
  end

  def activity_time_range(day)
      times = action_items.for_day(day).collect(&:performed_at).compact.sort
      times.first..times.last
  end

  def prescribed_interventions
    action_items.prescribed.where(component_type:Intervention::COMPONENT_TYPE).collect(&:intervention)
  end

  # def checks
  #   action_items.where(component_type:Check::COMPONENT_TYPE).collect(&:check)
  # end

  def activities
    Activity.where("action_item_uuid in (?)", action_items.collect(&:uuid))
  end

  def latest_activity
    activities.last ? activities.last : nil
  end
  def earliest_activity
    activities.first ? activities.first : nil
  end

  private

  def action_items_by_completion(completed, day=nil)
    if day
      action_items.prescribed.for_day(day).select {|ai| ai.complete? == completed }
    else
      action_items.prescribed.select {|ai| ai.complete? == completed }
    end
  end

end
