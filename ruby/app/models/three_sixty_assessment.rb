class ThreeSixtyAssessment < Assessment
  CATEGORIES = %w{focus positivity sleep social}.collect(&:to_sym)
  WAYS_TO_COMMUNICATE = %w{person phone text social email}.collect(&:to_sym)

  COMPONENT_TYPE = "three_sixty_assessment"

  has_many :supplimental_answers, class_name: 'ThreeSixtySupplimentalAnswers', primary_key: 'uuid', foreign_key: 'assessment_uuid', dependent: :destroy

  has_many :invitations, primary_key: 'uuid', foreign_key: 'subject', dependent: :destroy

  def self.find_unexpired_and_incomplete_assessment(enrollment, respondent_identifier)
    puts "find_unexpired_and_incomplete_assessment(#{enrollment}, #{respondent_identifier})"
    a=enrollment.assessments.three_sixty.last

    # puts " - nothing found" unless a
    # return nil unless a
    
    # puts " - assessment: #{a.uuid}"

    # expired = a.created_at < 1.month.ago
    # puts " - found, but old" if expired
    # return nil if expired

    # puts " - not expired"


    # completed_by_respondent = respondent_identifier && a.completed_by?(respondent_identifier)
    # puts " - found, but completed by user" if completed_by_respondent
    # return nil if completed_by_respondent

    # puts "  - all good, returning assessment #{a.uuid}"
    a
  end

  def expired?
    created_at < 1.month.ago
  end
  def active?
    incomplete? && ! expired?
  end

  def complete?
    responses.collect(&:respondent_identifier).uniq.count{|peep| completed_by?(peep)} >= 3
  end

  def completed_by?(respondent_identifier)
    unanswered_check_uuids_for(respondent_identifier).empty?
  end

  def incomplete?; ! complete?; end

  def action_item
    ActionItem.for_enrollment(enrollment).three_sixty_assessments.last
  end

  def answered_check_uuids_for(respondent_identifier)
    arr = responses.where(respondent_identifier:respondent_identifier).pluck(:check_uuid).uniq
    puts "Found #{arr.length} unique answered question for #{respondent_identifier}"
    arr
  end

  def unanswered_check_uuids
    # Check.three_sixty.pluck(:uuid).uniq - answered_check_uuids
    raise "use unanswered_check_uuids_for(respondent_identifier)"
  end
  def unanswered_check_uuids_for(respondent_identifier)
    check_uuids = Check.three_sixty.pluck(:uuid).uniq
    puts "check_uuids:#{check_uuids}"
    puts "answered_check_uuids_for(respondent_identifier):#{answered_check_uuids_for(respondent_identifier)}"
    check_uuids - answered_check_uuids_for(respondent_identifier)
  end

  def unanswered_checks
    # Check.where(uuid:unanswered_check_uuids)
    raise "use unanswered_checks_for(respondent_identifier)"
  end
  def unanswered_checks_for(respondent_identifier)
    Check.where(uuid:unanswered_check_uuids_for(respondent_identifier))
  end
    
  def results  # 1-100
    return nil if responses.count == 0
    {
        focus: focus_score,
        positivity: positivity_score,
        sleep: sleep_score,
        social: social_score,
    }
  end

  def focus_score
			responses.for_check_category(:focus).collect(&:adjusted_normal_score).average
  end

  def positivity_score
			responses.for_check_category(:positivity).collect(&:adjusted_normal_score).average
  end

  def sleep_score
      responses.for_check_category(:sleep).collect(&:adjusted_normal_score).average
  end

  def social_score
			responses.for_check_category(:social).collect(&:adjusted_normal_score).average
  end


end
