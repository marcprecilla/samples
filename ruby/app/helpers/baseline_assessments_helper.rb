# encoding: UTF-8
module BaselineAssessmentsHelper

  def prepare_baseline_assessment_attributes(enrollment)
    @baseline_levels = {}
    return unless baseline_assessment = enrollment.assessments.baseline.last

    assessment_results = baseline_assessment.try(:results)
    return unless assessment_results

    @focus_level = score_level_for_focus(assessment_results[:focus])
    @positivity_level = score_level_for_positivity(assessment_results[:positivity])
    @sleep_level = score_level_for_sleep(assessment_results[:sleep])
    @social_level = score_level_for_social(assessment_results[:social])

    @baseline_levels = { focus:@focus_level, positivity:@positivity_level, sleep:@sleep_level, social:@social_level }
  end

  def score_level_for_focus(score)
    return nil unless score
    if score > 80; :high
    elsif score > 50; :medium_high
    elsif score > 38; :medium_low
    else; :low
    end
  end

  def score_level_for_positivity(score)
    return nil unless score
    if score > 80; :high
    elsif score > 71; :medium_high
    elsif score > 60; :medium_low
    else; :low
    end
  end

  def score_level_for_sleep(score)
    return nil unless score
    if score > 73; :high
    elsif score > 60; :medium_high
    elsif score > 50; :medium_low
    else; :low
    end
  end

  def score_level_for_social(score)
    return nil unless score
    if score > 78; :high
    elsif score > 71; :medium_high
    elsif score > 63; :medium_low
    else; :low
    end
  end


  def score_label_for_level(level)
    case level
    when :low; "Low"
    when :medium_low; "Medium"
    when :medium_high; "Medium"
    when :high; "High"  
    end
  end
  def score_explination_for(level, type)
    return "" unless level && type
    BASELINE_SCORE_EXPLINATION_COPY[type.to_sym][level.to_sym]
  end

  def description_for_category(category)
    BASELINE_ASSESSMENT_CATEGORY_DESCRIPTIONS[category.to_sym]
  end

  def baseline_dial_meter_class_for_level(level)
    return nil if level.nil?

    case level.to_sym
    when :low; 'lowest'
    when :medium_low; 'low'
    when :medium_high; 'high'
    when :high; 'highest'
    else
      raise "unexpected level: #{level}"
    end
  end
  
  def three_sixty_dial_meter_class_for_level(level)
    return nil if level.nil?

    case level.to_sym
    when :low; 'lowest'
    when :medium_low; 'low'
    when :medium_high; 'high'
    when :high; 'highest'
    else
      raise "unexpected level: #{level}"
    end
  end


  BASELINE_ASSESSMENT_CATEGORY_DESCRIPTIONS = {
    focus:"Let's assess your Focus skills.",
    positivity:"Let's evaluate your aptitude for Positivity.",
    sleep:"Let's discuss your Sleep quality.",
    social:"Let's talk about your Social life."
  }

  BASELINE_SCORE_EXPLINATION_COPY = {
    focus:{
      high:"“An idle mind is the devil’s playground.”  Science shows that our ability, or lack thereof, to concentrate and be mindful of the present moment has deep implications on the quality of our lives.  What we pay attention to directly impacts our productivity, the quality of our relationships, and even our own levels of happiness.  Just as we can strengthen our muscles by going to the gym and physically exercising, we can strengthen our focus through mindfulness exercises.",
      medium_high:"Your score indicates that you have a great opportunity to strengthen the quality of your focus.  Perhaps your mind is guilty of worrying too much about the past or future.  Perhaps you find it very difficult to concentrate in your daily life.  Never fear – app is here.  We promise that by engaging in our Mind Fitness program, you will boost your ability to focus your mind to achieve your goals.  Focus is a skill that must be trained, just like any other skill.  With our exercises, we’ll be able to improve your focus in just a few short weeks.",
      medium_low:"Your score indicates that you have a great opportunity to strengthen the quality of your focus.  Whether you want to stop worrying about the past or future and become mindful of the present, or to feel in control of your ability to fully concentrate on what you are doing, app is here to help.  As you progress through app’s Mind Fitness program and engage in our focus exercises, you may notice your concentration becoming laser-like.  It may seem challenging at the moment, but we promise that by following the exercises in our program, you will learn to gain control of your mind so that you can focus your attention on the things that are most important and meaningful to your life.",
      low:"Your score indicates that you have a great opportunity to strengthen the quality of your focus.  Perhaps your mind is guilty of worrying too much about the past or future.  Perhaps you find it very difficult to concentrate in your daily life.  Never fear – app is here.  We promise that by engaging in our Mind Fitness program, you will boost your ability to focus your mind to achieve your goals.  Focus is a skill that must be trained, just like any other skill.  With our exercises, we’ll be able to improve your focus in just a few short weeks."
      },
    positivity:{
      high:"Your score indicates that you are one happy-go-lucky person!  Congratulations on being super positive.  It is important, however, to continue to build your positivity so that just in case any negative, stressful events rear their ugly heads in the future, you will be able to handle them with finesse by being mentally resilient.  Staying engaged with our Mind Fitness program and its positivity exercises will help take your positivity off the charts and ensure that you are living the good life!",
      medium_high:"Your score indicates that overall you are a pretty positive person.  You likely feel, however, that you have much to improve upon.  After all, there is no limit to how much positivity we can experience, and the benefits on our own health and happiness, as well as that of those we interact with, are infinite.  By practicing app’s positivity exercises over the next weeks and months, you may begin noticing an overflow of positive emotions, increased resilience to stress and negativity, and an overall boost in optimism and hope.  You know the saying, practice makes positive!",
      medium_low:"Your score indicates that you have a great opportunity to boost your positivity.  Just remember that your state is contagious – your positivity or negativity can spread to others around you, so why not spread the good over the bad?  Practicing app’s positivity exercises can help you boost your positivity to new heights, impacting the quality of your life and all those you come in contact with.  Let’s celebrate this opportunity to improve our own lives and those around us by getting started on our journey towards positivity!",
      low:"Sometimes life can get pretty sticky, but by taking this assessment, you are proving to yourself and the app team that you are here to take charge and turn your life into the positive, fulfilling, and thriving life that you deserve.  For whatever reasons, you may feel pessimistic about your future, but we assure you that by engaging in our positivity exercises, we will help you reshape your current state into one characterized by joy, love, hope, and optimism.  Let’s celebrate the beginning of our journey by getting started today!"
      },
    sleep:{
      high:"You are one lucky duck.  Your score indicates that you are one of the few people in the world who is satisfied with the quality of their sleep.  Of course, there is always room for improvement.  By using app’s guided sleep exercises that will help you fall into deep, refreshing slumber, you can maintain your high level zzzzzz and stay sharp, focused, and positive throughout the week!",
      medium_high:"Your score indicates that you’re no stranger to a good night’s rest.  But why settle for average when you can fully optimize the effectiveness of your sleep and feel fully refreshed each day?  As you progress through app’s Mind Fitness program, you may find that the quality and deepness of your sleep reaches a level you have only dreamed of (pun intended).  Giving ourselves the gift of a good sleep is one of the best things we can do for ourselves as we strive to take our lives from good to truly great.",
      medium_low:"Your score indicates that the quality of your sleep is not very good.  Most people do not prioritize sleep, and thus suffer for it in their daily lives.  Your body may be begging you for more sleep, and perhaps in the past, you have not listened to it as well as you should have.  As you progress through the app Mind Fitness program, you may find that the quality and deepness of your sleep also improves.  We need restful sleep in order to live full, healthy lives, so why not commit to the goal of optimizing your sleep in order to improve the entire quality of your life?",
      low:"Your score indicates that the quality of your sleep is deeply suffering.   Our bodies and minds need sleep so that they can be rejuvenated and ready to handle the challenges of the next day.  When our sleep quality is poor, we cannot hope to sustain any form of happiness, focus, or positive relationships for long.  Just as an architect must begin building a strong foundation before adding walls and rooms, so, too, must we build a strong foundation based on quality sleep before we can hope to sustain lasting well-being.  Fortunately, app is here to help by providing you some of the best exercises to help improve the quality and quantity of your sleep.",
      },
    social:{
      high:"Your score indicates that you feel pretty fulfilled with your relationships.  Be grateful that you have an abundance of closeness and support in your life!  But just because you currently score high in this dimension now, it is important to realize that without deliberate focus and attention, the quality of your relationships can slip.  Keep your relationships thriving by staying engaged with our Mind Fitness program, and watch your relationships reach heights you may have never even dreamed of!",
      medium_high:"Your score indicates that you feel satisfied with the quality of your relationships and your relationship skills, but that you realize that this area of your life has room for improvement.  And why not?  You deserve to have thriving, positive relationships that give you meaning, purpose and unconditional support!  As you progress through app’s Vital Mind program, you may notice your relationship skills, and thus the quality of your relationships, reaching their maximum potential.  We won’t stop providing you with rich content until your relationships transform from good to great.  You deserve only the best!",
      medium_low:"Your score indicates that boosting the quality of your relationships will be a large contributor to your overall mind fitness.  You may feel that you desire a greater amount of close relationships, or perhaps you wish to deepen the relationships that you do have by enhancing your interpersonal skills.  Fortunately, app’s Mind Fitness exercises are here to help and designed specifically for people like you.  As you progress through our program, you may notice your relationship skills, and thus the quality of your relationships, begin to improve.",
      low:"You have a great opportunity to boost the quality of your relationships.  For whatever reason, you feel that the relationships in your life lack closeness and intimacy.  Rather than submitting to these circumstances, you can take charge and begin to build positive relationship skills through the app Mind Fitness regimen.  Staying engaged with our program will help lead you to a life filled with thriving relationships."
      },

  }
end