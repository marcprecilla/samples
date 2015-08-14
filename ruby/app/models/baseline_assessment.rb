class BaselineAssessment < Assessment
  CATEGORIES = %w{focus positivity sleep social}.collect(&:to_sym)

  SUBCATEGORIES = %w{sleep 
    focus_thoughtlessness focus_worry 
    positivity_mindset positivity_hope 
    social_meaningful social_empathy}.collect(&:to_sym)

  COMPONENT_TYPE = "baseline_assessment"

  def self.find_unexpired_and_incomplete_assessment(enrollment)
    return nil if enrollment.nil?
    
    ba=enrollment.assessments.baseline.last
    return nil unless ba
    
    active = ba.incomplete? && ba.created_at > 1.month.ago
    ba.active? ? ba : nil
  end

  def self.category_for_subcatagory(subcategory)
    subcategory = subcategory.to_s
    if subcategory.include? "sleep"
      return :sleep
    elsif subcategory.include? "focus"
      return :focus
    elsif subcategory.include? "positivity"
      return :positivity
    elsif subcategory.include? "social"
      return :social
    else
      raise "invalid subcategory (#{subcategory} for BaselineAssessment.category_for_subcatagory"
    end
  end

  def self.subcategories_for_category(category)
    case category.to_sym
    when :sleep; [:sleep]
    when :focus; [:focus_thoughtlessness,:focus_worry]
    when :positivity; [:positivity_mindset,:positivity_hope]
    when :social; [:social_meaningful,:social_empathy]
    else
      raise "unexpected input: #{category}"
    end
  end

  def self.checks_for_category(category)
    subcategories = subcategories_for_category(category)
    Check.where(category:subcategories,check_type:'baseline')
  end

  def expired?
    created_at < 1.month.ago
  end
  def active?
    incomplete? && ! expired?
  end

  def complete?
    # checks.uniq.count == responses.collect(&:check).uniq.count
    unanswered_check_uuids.empty?
  end

  def mini_complete?
    # at least one question have been answered
     ! answered_check_uuids.empty?
  end

  def incomplete?; ! complete?; end

  def completed_at
    return nil unless complete?
    responses.last.created_at
  end

  def last_answered
    return nil if responses.empty?
    responses.last.created_at
  end

  def action_item
    # find the last baseline assessment ai that exists
    ActionItem.for_enrollment(enrollment).baseline_assessments.last
  end

  def answered_check_uuids
    responses.pluck(:check_uuid).uniq
  end
  def unanswered_check_uuids
    Check.baseline.pluck(:uuid).uniq - answered_check_uuids
  end
  def unanswered_checks
    Check.where(uuid:unanswered_check_uuids).order(:category)
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
      score_for_subcategories :focus_thoughtlessness, :focus_worry
  end

  def positivity_score
      score_for_subcategories :positivity_mindset, :positivity_hope
  end

  def sleep_score
      responses.for_check_category(:sleep).collect(&:adjusted_normal_score).average
  end

  def social_score
      score_for_subcategories :social_meaningful,:social_meaningful
  end

  private

  def score_for_subcategories(subcategory1, subcategory2)
      r1 = responses.for_check_category subcategory1
      r2 = responses.for_check_category subcategory2
      return nil unless r1 && r2 && r1.count > 1 && r2.count > 1

      Array.weighted_average(r1.collect(&:adjusted_normal_score), r2.collect(&:adjusted_normal_score))
  end
end
