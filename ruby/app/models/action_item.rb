#
#  An action item is be complete, skipped, and/or performed
#     skipped: marked as such in the database
#     performed: user wennt through and completed the exercise in the app
#     complete: either performed OR skipped,  the activity should not be shown in any todo list
#
class ActionItem < ActiveRecord::Base
  include UUIDRecord
  include PointsHelper

  attr_accessible :component_type, :component_uuid, :prescribed, :action_plan, :action_plan_uuid, :day, :skipped_at

  scope :for_day, ->(day)  { where(day:day) }
  scope :for_enrollment, ->(enrollment) { joins(:action_plan).where(action_plans:{enrollment_uuid:enrollment.uuid}) }

  scope :prescribed, where(prescribed: true)
  scope :extra, where(prescribed: false)

  scope :interventions, where(component_type:Intervention::COMPONENT_TYPE)
  scope :checks, where(component_type: Check::COMPONENT_TYPE)
  scope :baseline_assessments, where(component_type: BaselineAssessment::COMPONENT_TYPE)
  scope :three_sixty_assessments, where(component_type: ThreeSixtyAssessment::COMPONENT_TYPE)

  scope :visionboard, where(component_type: [Intention::COMPONENT_TYPE, Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE, Thank::COMPONENT_TYPE, Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE])
  scope :intentions, where(component_type: [Intention::COMPONENT_TYPE])
  scope :intention_visualizations, where(component_type: [Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE])
  scope :thanks, where(component_type: [Thank::COMPONENT_TYPE])
  scope :thank_visualizations, where(component_type: [Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE])

  belongs_to :action_plan, primary_key: 'uuid', foreign_key: 'action_plan_uuid'
  has_many :activities, primary_key: 'uuid', foreign_key: 'action_item_uuid', dependent: :destroy

  validates :day, inclusion: {in: 1..7}, unless: lambda {|ai| ai.day.nil?} # backwards compatibility

  delegate :week, to: :action_plan, allow_nil:true
  delegate :enrollment, to: :action_plan

  def self.find_active_action_item(enrollment, type)
    return nil if enrollment.nil?
    enrollment.action_plans.last.action_items.where(component_type:type).select(&:not_performed?).first
  end

  def effective_at
    puts "EFFECTIVE_AT: created_at:#{created_at.to_date.to_time.to_i}   day:#{day}"
    day ?  created_at + (day-1).days : created_at
  end

  # override the accessor to return a valid value '1' for a nil value.
  def day
    read_attribute(:day) || 1
  end

  # the sequential_day takes into account the week and day such that if week=2 and day=3 then the sequential_day is 10.
  def sequential_day
    puts "AI.sequential_day = #{action_plan.sequential_day} + #{day-1}"
    action_plan.sequential_day + day-1
  end
  def sequential_date
    # for existing users
    return action_plan.sequential_date if day.nil?
    # enrollment.created_at + sequential_day.days
    puts "AI.sequential_date = #{action_plan.sequential_date} (ap.s_date)) + #{day-1} days"

    action_plan.sequential_date + (day-1).days
  end

  def skip!
    update_attribute(:skipped_at, Time.now)
  end
  def unskip!
    update_attribute(:skipped_at, nil)
  end

  def points
    return 0 unless performed?

    case component_type.to_s
    when Intervention::COMPONENT_TYPE
      prescribed? ? ASSIGNED_INTERVENTION_POINTS : EXTRA_CREDIT_INTERVENTION_POINTS
    when Check::COMPONENT_TYPE
      ANSWER_ASSESSMENT_QUESTION_POINTS
    when Intention::COMPONENT_TYPE
      INTENTION_POINTS
    when Thank::COMPONENT_TYPE
      THANK_POINTS
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      VISBD_INTENTION_IMAGE_POINTS
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
       VISBD_THANK_IMAGE_POINTS
    when BaselineAssessment::COMPONENT_TYPE
       BASELINE_ASSESSMENT_POINTS
    end
  end

  def name
    if intervention
      intervention.key
    else
      "N/A" # TODO
    end
  end

  # If an action item is skipped, it is complete, but not performed (TODO: rename to performed)
  def performed?
    pa = performed_at
    ! pa.nil?
  end
  def not_performed?; !performed?; end

  def performed_at
    case component_type.to_sym
    when Check::COMPONENT_TYPE.to_sym
      return nil unless check
      
      # TODO Expensive
      check.responses.for_enrollment(enrollment).where(created_at:created_at..Time.now).last.try(:updated_at)
      
    when Intention::COMPONENT_TYPE.to_sym
      intention.try(:updated_at)
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE.to_sym
      events_within_a_week(Intention::VISUALIZED_EVENT).pluck(:created_at).sort.last
    when Thank::COMPONENT_TYPE.to_sym
      thank.try(:updated_at)
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE.to_sym
      events_within_a_week(Thank::VISUALIZED_EVENT).pluck(:created_at).sort.last
    when BaselineAssessment::COMPONENT_TYPE.to_sym
      assessment = enrollment.assessments.baseline.last
      assessment && assessment.complete? ? assessment.updated_at : nil
    else
      activities.pluck(:created_at).sort.last
    end

  end

  # If an action item is skipped, it is complete, but not performed
  def complete?
    return true unless skipped_at.nil?  # a skipped action item is considered complete. Lazy fucks.
    performed?
  end
  def incomplete?; !complete?; end

  def completed_at
    skipped_at || performed_at
  end

  def skipped?
    ! skipped_at.nil?
  end

  def intervention
    Intervention.find_by_uuid component_uuid
  end
  def check
    Check.find_by_uuid component_uuid
  end
  def checkin_type
    return nil unless component_type == 'check'
    return nil unless check # this line is here to support pre-Eddie checkins (checkin type is nil in this case, unless we go back and handle them appropriately)
    subcategory = check.try(:category) # focus_1, positivity_3, etc
    subcategory.split('_').first
  end

  def intention
    Intention.find_by_uuid component_uuid
  end
  def thank
    Thank.find_by_uuid component_uuid
  end

  private

  def events_within_a_week(event_type)
    from = created_at
    to = from + 7.days
    Event.where(created_at:from..to, type: event_type, enrollment_uuid:enrollment.uuid)
  end

end
