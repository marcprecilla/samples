class Enrollment < ActiveRecord::Base
  include UUIDRecord
  
  scope :subscribed, joins(:user).where("users.subscription_plan_uuid IS NOT NULL")

  attr_accessible :program, :program_uuid, :user, :user_uuid, :uuid, :intervention_preferences, :last_seen

  belongs_to :program, primary_key: 'uuid', foreign_key: 'program_uuid'
  belongs_to :user, primary_key: 'uuid', foreign_key: 'user_uuid'

  has_many :benefits, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy
  has_many :activities, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy
  has_many :action_plans, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy
  has_many :assessments, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy
  has_many :intentions, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy
  has_many :thanks, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy
  has_many :happy_face_intervention_scores, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy

  has_many :events, primary_key: 'uuid', foreign_key: 'enrollment_uuid', dependent: :destroy

  validates :program_uuid, presence: true
  validates :user_uuid, presence: true

  serialize :intervention_preferences, Hash

  def current_action_plan
    action_plans.last
  end

  def personality_assessment_completed?
    assessments.pre_paywall.last.try(:include_personality?)
  end

  # def mini_baseline_assessment_completed?
  #   !!assessments.baseline.last.try(:positivity_score)
  # end

  def number_of_unique_activities_completed
    activities.select("distinct intervention_uuid").count
  end

  def start_date
    # start of day is 4AM EST
    start_time = created_at.in_time_zone('EST')
    start_time.hour < 4 ? start_time.yesterday.to_date : start_time.to_date
  end

  def latest_activity
    activities.order("created_at DESC").first
  end

  def week
    action_plans.last.week
  end

  def events_by_action_plan
    plans = action_plans

    logger.info("action_plan time boundries: #{plans.collect(&:created_at)}")

    events_by_plan={}

    prev = action_plans.shift
    while(curr=action_plans.shift)
      events_by_plan[prev] = events.where(created_at:prev.created_at..curr.created_at)
      prev=curr
    end

    events_by_plan
  end

  def points
    events.with_points.pluck(:points).sum
  end
  def points_since(time)
    events.with_points.since(time).pluck(:points).sum
  end
  def points_between(range)
    events.with_points.between(range).pluck(:points).sum
  end

  # login metrics 
  def login_dates
    events.new_session.order(:created_at).collect {|e|e.created_at.beginning_of_day}.uniq
  end

  def longest_consecutive_days_logged_in # i.e. streak
    longest_streak = 0
    current_streak = 0

    dates = login_dates
    last_date = dates.shift

    for date in dates
      current_streak += 1 if (date - last_date) <= 1.day
      longest_streak = current_streak if current_streak > longest_streak
      last_date = date
    end

    longest_streak
  end

  def all_action_items
    ActionItem.joins(:action_plan).where("action_plans.enrollment_uuid = '#{uuid}'")
  end
  def number_of_skipped_days
    all_action_items.where("skipped_at is not null").collect{|ai|"#{ai.action_plan.week}-#{ai.day}"}.uniq.count
  end

  def days_performed
    days_performed_or_skipped = (current_action_plan.week-1)*7 + (current_action_plan.day-1) 
    days_performed_or_skipped - number_of_skipped_days
  end

end
