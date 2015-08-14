module VisionboardHelper
  def show_intention?
    @show_intention == true
  end
  alias :show_intentions? :show_intention?

  def show_gratitude?
    ! show_intention?
  end

  def url_for_visionboard_action_item(ai)
    case ai.component_type
    when Intention::COMPONENT_TYPE
      new_intention_url
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      intentions_url
    when Thank::COMPONENT_TYPE
      new_thank_url
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      thanks_url
    end
  end

  def type_for_visionboard_action_item(ai)
    case ai.component_type
    when Intention::COMPONENT_TYPE
      "intention"
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      "intention"
    when Thank::COMPONENT_TYPE
      "thank"
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      "thank"
    end
  end

  def title_for_visionboard_action_item(ai)
    case ai.component_type
    when Intention::COMPONENT_TYPE
      "Set intention"
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      "Visualize Intentions"
    when Thank::COMPONENT_TYPE
      "Build Gratitude"
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      "Visualize Gratitude"
    end
  end
  def description_for_visionboard_action_item(ai)
    case ai.component_type
    when Intention::COMPONENT_TYPE
      ["Set a new intention.", "Affirm your future.", "What is your intention?"].sample
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      ["Add photos to your vision.", "Visualize your future.", "Expand your vision."].sample
    when Thank::COMPONENT_TYPE
      ["Be thankful.", "Express gratitude.", "Say thank you."].sample
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      ["Add photos to your vision.", "Show your gratitude.", "Expand your vision."].sample
    end
  end
  def activity_description_for_visionboard_action_item(ai)
    case ai.component_type
    when Intention::COMPONENT_TYPE
      "Identify something you want to affirm in your life."
    when Intention::VISIONBOARD_ADDITION_COMPONENT_TYPE
      "Add photos to visually affirm things you want in your life."
    when Thank::COMPONENT_TYPE
      "Identify something you appreciate in your life."
    when Thank::VISIONBOARD_ADDITION_COMPONENT_TYPE
      "Add photos to remind you of what you appreciate."
    end
  end

  def other_users_vision_board_entry
    rand(2)==0 ? other_users_vision_board_intention_entry : other_users_vision_board_thank_entry
  end

  def other_users_vision_board_intention_entry
    prefix = [
        "A app user intends to be",
        "Anonymous intends to be",
      ].sample

    intent = [
      "a great father.",
      "romantic.",
      "friendly.",
      "listen actively.",
      "happy.",
      "rich.",
      "stronger.",
      "vibrant.",
      "running everyday ",
      "saving the world",
      "eating healthy",
      "living strong",
      "being awesome",
      "smiling ",
      "on top of the world",
      "having my cake",
      "in love with life",
      "curious ",
      "excited",
      "a photographer",
      "a writer",
      "reporting the truth",
      "a rock",
      "a good son",
      "#WINNING",
      "a great listener",
      "the best kisser",
      "superman",
      "sincere",
      "a safe driver",
      "fearless",
      "responsible",
      "a social butterfly",
      "the life of the party",
      "my dad's friend",
      "my sister's rock",
      "a good example",
    ].sample

    "#{prefix} #{intent}"
  end
  def other_users_vision_board_thank_entry
    g = %w{
      Acceptance Accountability Animals Animals Apologies Art Art August Bathing%Suits Bathing%Suits best%friends Blogs Blogs Books Books cartoons Challenges Change Choice Clothes Color Comfort Compassion Compliments Computers Coziness Creativity Dancing Disappointment Dogs Dreams Driving Earth Emotions Encouragement Energy
      Enthusiasm Excitement Family family Fears Films Food Forgiveness Freedom Friends friends Fun Generosity Gifts Glitter good%health Good%News Gratitude Growing%Up hands Handwriting Happiness Health Hearing heart Heartbreaks Holidays home Honesty Hope Housing Hugs Imagination Independence Inspiration
      Journals Joy Justin%Bieber Kind%strangers Kindness Kisses Knowledge Laughter Laughter Laughter Laughter Laughter Laughter legs Les%Miserable Life Life Life Life Life Life Love Love love lungs Magic Memories mind mistakes Mother%nature Movies Music Music Music my%health my%immune%system my%iPhone my%phone
      my%soul%mate Nature New%Places New%Places Now Opinions Organization Oxygen Pain Palm%trees parents Passion Patience Paw%prints Peace Photographs Plans Poetry Positivity Productivity Quality%Time Questions Rain Rainbows Rainbows Respect rest Sadness Safe%Landings Safety salt school Seasons Shoes Sight Sleep sleep Smell Smiles
      Snow Speech Spring Stars Strength Summer Sunrise Sunset Sunshine Surprises Taste Teachers Tears Technology The%Earth The%Moon%and%Stars The%Sun Therapy Thoughts Time Touch Twitter Water Weekends Winter Wonderlands Words
      health%insurance my%sister my%twitter%feed the%BBC
      good%food clean%water cartoons being%healthy good%friends music%shows a%glass%of%wine
      having%a%job
      the%Internet
    }.sample.gsub('%',' ')
    "Someone is grateful for #{g}."
  end

  def intention_image_url(intention, index)
    intention.image_urls[index]
  end
  def thank_image_url(thank, index)
    thank.image_urls[index]
  end
end