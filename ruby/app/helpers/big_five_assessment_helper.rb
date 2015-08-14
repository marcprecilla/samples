module BigFiveAssessmentHelper
  COMPONENT_TYPE = "pre_paywall_assessment"

  def include_personality?
    @big_five_questions && @big_five_questions.length > 0
  end


  def score
    begin
      {
        extraversion: value_for("I+") - value_for("I-"),
        agreeableness: value_for("II+") - value_for("II-"),
        conscientiousness: value_for("III+") - value_for("III-"),
        emotional_stability: value_for("IV+") - value_for("IV-"),
        intellect: value_for("V+") - value_for("V-")
      }
    rescue
      nil
    end
  end

  def results
    return nil unless responses.count > 0

    ordered_factors.collect do |factor,score|
      name = name_for(factor, score)
      {
        name:name,
        description:description_for(factor, score),
        symbol: name.downcase.to_sym
      }
    end
  end

  def ordered_factors
    scores = score
    res = []

    return [] unless scores

    while !scores.empty?
      factor, s = scores.max_by {|x| x.last.abs}
      res << [factor.to_sym, s]
      scores.delete factor
    end
    res
  end

  def name_for(factor, score)
    info = FACTOR_INFO[factor]
    score >= 0 ? info[:positive_label] : info[:negative_label]
  end
  def description_for(factor, score)
    info = FACTOR_INFO[factor]
    score >= 0 ? info[:positive_text] : info[:negative_text]
  end

  # def self.info_for(factor, score)
  #   copy_array = FACTOR_INFO[factor.to_sym]
  #   raise "DEV ERROR 73003: invalid factor name (#{factor}) in description_for" unless copy_array
  #   score >= 0 ? copy_array.first : copy_array.last
  # end

  # one of "I+ I- II+ II- III+III-IV+ IV- V+ V-"
  def value_for(category)
    logger.info "value_for(#{category}) = #{response_for(category).value}"
    response_for(category).value.to_i
  end

  # included
  def response_for(category)
    responses.detect {|r| r.check.category == category}
  end

 FACTOR_INFO = {
    extraversion:{
        positive_label: "Extroverted",
        negative_label: "Introverted",
        positive_text: "Extroverts direct their attention outward, toward friends, family and the world they live in. People who are extroverted tend to be headstrong, talkative and are energized from being around others.",
        negative_text: "Introverts direct their energy inward, spending a lot of time reflecting upon their own thoughts and feelings. People who are introverted tend to be quiet, low-key, and comfortable spending time by themselves.",
  },
  agreeableness:{
        positive_label: "Friendly",
        negative_label: "Independent",
        positive_text: "Friendly people are warm, helpful and welcoming to others.  They get along easily with others and tend to maintain strong social relationships over long periods of time.",
        negative_text: "Independent people take pride in taking matters into their own hands.  They know that they must help themselves before helping others, and expect other people to do the same.",
  },
  conscientiousness:{
          positive_label: "Conscientious",
        negative_label: "Free Spirited",
        positive_text: "Conscientiousness reflects the tendency to control, regulate, and manage one's impulses. Conscientious people tend to be efficient, well-organized, reliable, and responsible.",
        negative_text: "Free-spiritedness refers to the tendency to give in to one's impulses, or to put uninteresting tasks aside. Free-spirited people tend to work well in chaotic environments and adjust to change quickly.",
  },
  emotional_stability:{
        positive_label: "Resilient",
        negative_label: "Emotional",
        positive_text: "Those who are resilient tend to feel calm and free of chronic negative emotions such as anxiety and depression. This means fewer mood swings and the ability to handle stress and pressure well.",
        negative_text: "People who are emotional embrace the full spectrum of their feelings.  While this means they fully experience life's pleasures, at times, they may find normal life situations to be overwhelming.",
  },
  intellect:{
        positive_label: "Imaginative",
        negative_label: "Practical",
        positive_text: "Imaginative people tend to be interested and curious about many things. Generally, they find strength in being creative, seeking knowledge and participating in the arts and culture.",
        negative_text: "Those who are practical prefer familiarity and are good at solving the problem at hand. Practical people tend to be down-to-earth, realistic, straightforward, and have little tolerance for ambiguity or complexity.",
  },
}
end
