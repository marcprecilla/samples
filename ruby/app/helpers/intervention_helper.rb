# encoding: UTF-8
module InterventionHelper
  ORDERED_LIST_OF_INTERVENTIONS = %w{ savoring_album_sight diaphragmatic_breathing thank_bank_work change_something_object sleep_intervention_1 mindfulness_meditation breath_counting progressive_muscle_relaxation savoring_album_sound sleep_intervention_2 equal_breathing thank_bank_personal_interests sleep_intervention_3 body_awareness_meditation interacting_with_nature compassion_meditation savoring_album_touch thank_bank_relationships thank_you_day bellows_breath savoring_album_meal no_complaining compassion_meditation change_something_location savoring_album_touch best_future_visualization savoring_album_smell thank_bank_relationships thank_bank_health gratitude_meditation }.collect(&:to_sym)
  INTERVENTION_IMAGE_BASE = "https://s3.amazonaws.com/s3.stresslessapp.myapp.com/interventions"

  def assessment_image_urls(intervention)
    intervention.transitions.collect { |trans| intervention_image_link(trans["image"], intervention) }
  end
  def intervention_image_link(image_url, intervention)
    if image_url
      image_url = "#{INTERVENTION_IMAGE_BASE}/#{image_url}" unless image_url.include? "http"
    end
    image_url || intervention.image_url
  end
  # def default_image_for_day(day)
  #   throw "dev error: no day was provided!" unless day
  # 	"https://s3.amazonaws.com/s3.stresslessapp.myapp.com/interventions/day#{day}_600x600.jpg"
  # end

  def image_for_intervention(intervention)
    intervention.image_url
  end

  def url_for_new_intervention(intervention_sym)
    "/intervention/new/#{intervention_sym}"
  end
  def url_for_new_activity(intervention_sym)
    "/activity/new/#{intervention_sym}"
  end

  def intervention_type_for_intervention_sym(intervention_sym)
    "Guided"
  end

  def category_for_intervention_sym(intervention_sym)
    intervention_sym = intervention_sym.to_sym
    load_intervention_metadata if @positivity_interventions.nil?

    return "Positivity" if @positivity_interventions.include?(intervention_sym)
    return "Focus" if @focus_interventions.include?(intervention_sym)
    return "Social" if @social_interventions.include?(intervention_sym)
    return "Sleep" if @sleep_interventions.include?(intervention_sym)
    raise "Developer Error #448837"
  end
  def category_sym_for_intervention_sym(intervention_sym)
    category_for_intervention_sym(intervention_sym).gsub(" ","_").downcase.to_sym
  end

  def load_intervention_metadata
    @positivity_interventions = sorted [
      :thank_bank_personal_interests,
      :thank_bank_health,
      :savoring_album_sight,
      :savoring_album_sound,
      :interacting_with_nature,
      :savoring_album_touch,
      :savoring_album_meal,
      :best_future_visualization,
      :savoring_album_smell,
      :thank_bank_work,
    ]

    @focus_interventions = sorted [ # was mindfulness_interventions
      :body_awareness_meditation,
      :change_something_object,
      :mindfulness_meditation,
      :progressive_muscle_relaxation,
      :bellows_breath,
      :equal_breathing,
      :breath_counting,
      :change_something_location,
      :diaphragmatic_breathing,
    ]
    
    @social_interventions = sorted [  # was gratitude_interventions
      :thank_bank_relationships,
      :thank_you_day,
      :gratitude_meditation,
      :compassion_meditation,
      :no_complaining
    ]

    @sleep_interventions = sorted [
      :sleep_intervention_1,
      :sleep_intervention_2,
      :sleep_intervention_3
    ]

    @intervention_names = {
      :bellows_breath => 'Focus on Breathing',
      :best_future_visualization => "Imagine the Future",
      :body_awareness_meditation => 'Discover You',
      :breath_counting => 'Count Your Breaths',
      :change_something_location => 'Go Somewhere New',
      :change_something_object => 'Find The "Now"',
      :compassion_meditation => "Love and Kindness",
      :diaphragmatic_breathing => "Breathe Deeply",
      :equal_breathing => 'Breathe Steadily',
      :gratitude_meditation => 'Appreciate Your Life',
      :interacting_with_nature => 'Embrace Nature',
      :mindfulness_meditation => "Stay Sharp",
      :no_complaining => "Avoid the Negative",
      :progressive_muscle_relaxation => "Find Your Center",
      :savoring_album_meal => "Have Your Cake",
      :savoring_album_sight => "Savor the Sights",
      :savoring_album_smell => "Smell the Roses",
      :savoring_album_sound => "Savor the Sounds",
      :savoring_album_touch => "Think & Feel",
      :sleep_intervention_1 => "Get Beauty Sleep",
      :sleep_intervention_2 => "Sweet Dreams",
      :sleep_intervention_3 => "Sleep Deep",
      :thank_bank_health => "Appreciate Health",
      :thank_bank_personal_interests => "Feel Passion",
      :thank_bank_relationships => "Build Love & Passion",
      :thank_bank_work => "Inspire Yourself",
      :thank_you_day => "Notice the Positive",
    }
  end


TOOLTIP_INFO = {
   best_future_visualization: ["In groundbreaking research studying the neural mechanisms of optimism, Dr. Tali Sharot’s team used functional magnetic resonance imaging (FMRI) to look at the brains of people who imagined good events in their future life. They found increased activity in the rostral anterior cingulate cortex (rACC) - a part of the brain’s preforntal cortex that is responsible for long-term emotional health and well-being,","Source: Sharot T, Riccardi AM, Raio CM, Phelps EA. Neural mechanisms mediating optimism bias. Nature. 2007 Oct 24; "],
   diaphragmatic_breathing: ["In a study published in 2011, researchers at the University of Camerino, Italy analyzed the antioxidant defense mechanism of athletes after engaging in exhaustive exercise. They found that Diaphragmatic Breathing is tied to a decrease of about 25%  in secretion of the Cortisol stress hormone compared to a control group, and as a result a reduced long term adverse effect of free radicals. ","Source: \"Diaphragmatic Breathing Reduces Exercise-Induced Oxidative Stress\", Evidence-Based Complementary and Alternative Medicine, Volume 2011 (2011), Article ID 932430, 10 pages doi:10.1093/ecam/nep169"],
   progressive_muscle_relaxation: ["Messages from the muscles travel to the brain and change its chemistry:   In a study conducted at Harvard Medical School , researchers found that practicing  Progressive Muscle Relaxation affects the brain’s cingulate cortex  and thalamus regions, altering the nitric oxide mechanism of communications between brain cells, resulting in an overall brain relaxation response.","Source: Stefano et al, “The placebo effect and relaxation response: neural processes and their coupling to constitutive nitric oxide,” Brain Research Reviews,  Volume 35, Issue 1, March 2001, Pages 1–19"],
   savoring_album_meal:   ["In a study published in 2011, Researchers at the University of Cape Town, South Africa, found that mindful behavior (exhibiting heightened awareness to the present moment) reduces brain activity in regions associated with the sensitivity to internal stimulation and increases activity in external-processing regions, thus explaining the feelings of connectedness that mindful behavior invokes.","Source: “The Neural Substrates of Mindfulness: an fMRI investigation”, Soc. Neurosci. 2011;6(3),
231-42. doi: 10.1080/17470919.2010.513495. Epub 2010 Sep 9."],
   savoring_album_sight:    ["Visual beauty evokes positive emotions in the “right places” in the brain. In a 2004 study people were asked to look at pictures of art and natural beauty while their brains were scanned. The images revealed heightened activity in the Preforntal Dorsolateral Cortex, a brain region that is a hub of emotional processing used in transcranial magnetic stimulation treatment of depression.","Source: Cela-Conde, et al,” Activation of the Prefrontal Cortex in the Human Visual Aesthetic Perception,” National Academy of Sciences, 101(16), 6321-6325, 2004."],
   savoring_album_smell:    ["Smells are hard-wired to emotions. The olfactory bulb, responsible for the brain’s processing of smells, is a part of the brain limbic system, sometimes called the “lizard brain”. When certain scents are sensed, deep brain parts like the Amygdala immediately “light up” resulting in a flood of intense emotions. Good scents can therefore trigger an immediate sense of well-being.",""],
   savoring_album_sound:    ["Listening to pleasant sounds like music triggers the brain’s reward system. In a joint study of the emotional brain responses to music, Stanford and McGill University researchers have found that listening to pleasant music results in the release of dopamine, and the activation of various reward brain regions, including the nucleus accumbens, resulting in significant emotional pleasure.","Source: Menon na Levitin ,”The rewards of music listening: Response and physiological connectivity of the mesolimbic system,” Neuroimage, Volume 28, Issue 1, 15 October 2005, Pages 175–184."],
   savoring_album_touch:    ["Our sense of touch is tuned for slow, gentle touch. A recent study reviewing the neural mechanisms of touch unveils that skin sensory neurons are programed to sense slow, pleasant touch, evoking a response in the brain’s insular cortex, and associated with pleasant and social aspects of this sense. ","Source: Olausoon et al, “The neurophysiology of unmyelinated tactile afferents,” Neuroscience and  Biobehavioral Review, Feb;34(2) 2010."],
   thank_bank_health:     ["Grateful individuals enjoy better physical health. In a study published in January of 2013, researchers at the University of Illinois studied a group of 962 Swiss adults, ages 19 to 84. They found that people who tend to be more grateful reported significantly better physical health, a healthier lifestyle, and a more proactive approach in seeking medical help.","Source: Hill, Allemand, and Roberts, “Examining the Pathways between Gratitude and Self-Rated Physical Health across Adulthood,”Personality and  Individ Differences, 2013 Jan;54(1):92-96."],
   thank_bank_personal_interests:   ["Gratitude is an antidote to materialistic frustration. In 2012 Drs. Randy and Lori Sansone, psychiatrists at the Wright State University School of Medicine surveyed the entire body of social science research linking gratitude and well-being. They found a consistent positive correlation between well-being and grateful behavior. In particular, gratitude was found to reduce the negative effect of unfulfilled materialistic “cravings”.","Source: Sansone and Sansone, “Gratitude and Well Being – The Benefits of Appreciation”, Psychiatry (Edgmont). 2010 November; 7(11): 18–22."],
   thank_bank_relationships:  ["Positive Psychologist Sara Algoe and her collaborators studied the way gratitude affects romantic relationships. Using predictive models, they were able to predict the quality and duration of relationships using small, daily displays of gratitude between partners.","Source: Algoe, Gable, & Maisel,”It’s the little things: Everyday gratitude as a booster shot for romantic relationships,” Personal Relationships, 17, 217-233. 2010."],
   thank_bank_work:     ["People who learn to be grateful can lower their level of stress hormones. In a study published in 1998, 45 individuals were trained for 4 weeks in cultivating feelings of gratitude and appreciation. At the end of their training, their measured levels of the Cortisol stress hormone were 23% lower on average.","People who learn to be grateful can lower their level of stress hormones. In a study published in 1998, 45 individuals were trained for 4 weeks in cultivating feelings of gratitude and appreciation. At the end of their training, their measured levels of the Cortisol stress hormone were 23% lower on average."],
   bellows_breath:        ["Practicing the “Bellows Breath” exercise tends to activate the sympathetic nervous system resulting in higher levels of arousal and sharper senses, useful in getting out of emotional “downs”. It also enhances blood oxygen levels, creating a natural sense of mental alertness.",""],
   body_awareness_meditation: ["Mindfulness blocks bad emotional hits: Research published in Social Cognitive and Affective Neuroscience in 2012 has shown that individuals who are more mindful experience reduced negative emotional responses, as mindfulness modulates the immediate neural processing of emotions.","Source: Brown, Goodman, and Inzlicht, “dispositional mindfulness and the attenuation of neural responses to emotional stimuli,” Social Cognitive and Affective Neuroscience. doi: 10.1093/scan/nss004"],
   breath_counting:     ["Being right here and right now pays off. Benefits to the immune system, stress hormone secretion, health behavior, and lifestyle, are only some of the benefits of mindful behavior found by Dr. Jeffery Greeson if Duke University. Greeson surveyed 52 different studies In his meta- study, published in the Journal of Evidence-Based Complementary & Alternative Medicine in 2009.","Source: Greeson, “Mindfulness research update: 2008,” Journal of Evidence-Based Complementary & Alternative Medicine January 2009 vol. 14 no. 1 10-18"],
   change_something_location: ["Mindfulness practice builds gray matter. In a 2011 study conducted at Harvard and Massachusetts General Hospital, a group of 16 healthy adults were asked to go through an 8 week mindfulness training program. At the end of training, the researchers had their brains scanned and compared the images to a group that has been waiting to receive the training. They found that mindfulness training resulted in denser gray matter in the brain in areas pertaining to learning, memory, and emotion regulation.","Source: Hölzel et al, “Mindfulness practice leads to increases in regional brain gray matter density,” Psychiatry Res. 2011 Jan 30;191(1):36-43. doi: 10.1016/j.pscychresns.2010.08.006. Epub 2010 Nov 10 "],
   change_something_object: ["Mindfulness brings willpower. In a new study published in December 2012 Researchers at Yale and University of New Mexico showed that mindfulness training (followed by self-guided mindfulness practice) significantly helped smokers quit by decoupling the cravings and smoking triggers.","Source: Elwafi, et al , “Mindfulness training for smoking cessation: Moderation of the relationship between craving and cigarette use” Drug and Alcohol Dependence, 20 December 2012, ISSN 0376-8716, 10.1016/j.drugalcdep.2012.11.015."],
   compassion_meditation:   ["Meditation may help delay the process of ageing. In a study conducted in Dr. Sara Lazar’s lab at Harvard Medical School in 2005, individuals who practiced meditation consistently for years have not experienced the thinning of brain regions related to attention and sensory function that naturally occurs with ageing.","Source: Neuroscience 2005, annual meeting of the Society for Neuroscience, Washington, Nov. 12-16, 2005"],
   equal_breathing:     ["Breathing activates important brain regions. In 2007, brain scientists in the Bender Institute for Neuroimaging in Germany compared meditators to non-meditators performing a breathing exercise. They found increased activity in the Rostral Anterior Cingulate Cortex (rACC) – a brain region that is strongly tied to the ability to regulate one’s emotions.","Source: Ho¨lzel et al. (2007) “Differential engagement of anterior cingulated and adjacent medial frontal cortex in adept meditators and non-meditators” Neuroscience Letters, 421(1), 16–21. "],
   gratitude_meditation:    ["Feelings of gratitude are tied to networks of neurons in the prefrontal regions of the brain – the same regions that regulate emotions and are the most flexibly modified using various forms of therapy and meditation. In a study conducted with patients of Parkinson’s Disease, researchers found the PD patients did not experience the same boost in positive emotion from practicing gratitude compared to healthy individuals, as a result of dysfunction in the prefrontal cortex.","Source: Emmons and McNamara ,” Sacred Emotions and Affective Neuroscience: Gratitude, Costly Signaling, and the Brain,” Chapter 2 in Religion and the Brain Series: “Where God and Science Meet” "],
   interacting_with_nature: ["Being in nature and interacting in it feeds your brain. Being in nature provides a strong sense of connectedness - one of the three major human needs that spark motivation according to Self Determination Theory. Natural scenery also triggers strong executive-level processing in the brain, filling the circuits with positive stimuli replacing worry and concern cycles. ",""],
   mindfulness_meditation:    ["Practicing mindfulness meditation over time results in changes in the brain. In a 2011 survey of neuroscience research tied to mindfulness meditation, Dr. Michael Baime of UPenn presents studies showing that the practice of mindfulness meditation results in beneficial structural changes in the brain in as little as eight weeks. He also shows that this outcome is sustainable: the thickness of the prefrontal brain is well maintained over the years for meditators, while the rest of us lose about 10% of prefrontal thickness between ages 30 and 50.","Source: Baime, “This is your brain on mindfulness” Shambhala Sun, July 2011 "],
   no_complaining:        ["Optimistic people enjoy better close relationships and have more satisfied romantic partners. In a study published in 2006, a joint team of researchers at the University of Oregon, Stanford University, University of Texas at Austin, and University of Arizona studied the effects of optimism on romantic relationships. They found that optimistic individuals were perceived as providing better support, resolved conflicts more constructively, and maintain longer relationships.","Source: “Optimism in Close Relationships: How Seeing Things in a Positive Light Makes Them So” Journal of Personality and Social Psychology, 2006, Vol. 91, No. 1, 143–153 "],
   sleep_intervention_1:    ["Sleep sharpens your memory. In a study published in Nature in 2006, Dr. Robert Stickgold, head of Harvard University’s Center for Sleep and Cognition, reported experiments demonstrating how the brain reinforces memory during different stages of sleep. Individuals in his experiments were able to remember a significantly larger number of words that they memorized before going to sleep.","Source: Stickgold, “Neuroscience: A memory boost while you sleep,” Nature 444, 559-560 (30 November 2006) | doi:10.1038/nature05309 "],
   sleep_intervention_2:    ["Sleep keeps your natural sobriety. Sleeping only 4 hours a night for a few days results in the same level of cognitive impairment as legal drunkenness: reaction times are longer, judgement is impeded, and the ability to solve problems is greatly reduced. According to sleep researcher Charles Czeisler, sleep-deprivation is also similar to drunkenness in the sense that the “drunk” is not aware of her or his state.","Source: \"Sleep Deficit: The Performance Killer,\" A Conversation with Charles A. Czeisler by Bronwyn Fryer, Harvard Business Review, October 2006"],
   sleep_intervention_3:    ["Good sleep brings longevity. In a study conducted over the course of more than 15 years, researchers at the University of California in San Diego looked at the ties between life expectancy of individuals and at their sleep patterns. After removing the effect of various health conditions, they found that people who slept less than 5 hours a day on average, were at a significantly lower probability of survival. ","Source: Kripke et al, “Mortality related to actigraphic long and short sleep,” Sleep Medicine, 2011 Jan;12(1):28-33. doi: 10.1016/j.sleep.2010.04.016. Epub 2010 Sep 25"],
   thank_you_day:       ["Grateful people get better immunization from their flu shots. In a joint study between the University of Wisconsin and Princeton University, individuals receiving a flu shot were asked to write about themselves and then have their brain waves measured using an EEG sensor. The ones who wrote positively and measured EEG waves associated with positive emotions had a significantly better immune system response to the Influenza Vaccine. ","Source: Rosenkranz et al, “Affective style and in vivo immune response: Neurobehavioral mechanisms,” Proceedings of the National Academy of Sciences 100.19 (2003),
 11148-11152."],
}
def why_text(intervention_sym)
  load_intervention_metadata if @positivity_interventions.nil?
  TOOLTIP_INFO[intervention_sym.to_sym].first
end
def why_source(intervention_sym)
  load_intervention_metadata if @positivity_interventions.nil?
  TOOLTIP_INFO[intervention_sym.to_sym].last
end


  private

  def sorted(intervention_syms)
    intervention_syms.sort { |x,y| ORDERED_LIST_OF_INTERVENTIONS.index(x) <=> ORDERED_LIST_OF_INTERVENTIONS.index(y) }
  end
end
