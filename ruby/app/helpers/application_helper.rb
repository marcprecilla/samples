# encoding: UTF-8
module ApplicationHelper
  def stress_less_program
    @program ||= Program.where(name: "Stress Less").first
  end


  WEEK_THEMES = [
    "Open up to others",
    "Keep at your center",
    "Take a breather",
    "Close your eyes and dream",
    "Share your positivitiy",
    "Keep connected and slow things down a notch",
    "Pause, breathe, reframe",
    "Bring your mind back form wandering",
    "Listen up",
    "Focus on the present",
    "Live in the now",
    "Destress and get some rest",
    "Recognizing that \"it's all good\"",
    "Get replenishing and energizing sleep",
    "Use your mental muscle to bring down stress",
    "Keep it up",
    "Flourish"]


  def current_first_name
    current_user.try(:first_name) || current_lead.try(:first_name)
  end
  def current_last_name
    current_user.try(:last_name) || current_lead.try(:last_name)
  end
  def current_email
    current_user.try(:email) || current_lead.try(:email)
  end
  
  def profile_image_url
    user = current_user
    user = User.find_by_uuid(user.uuid) if user.email.nil?

    url = user.profile_image_url
    if url.nil?
      url = user.female? ? "/assets/female_avatar.png" : "/assets/male_avatar.v2.png"
    else
      url.sub!("type=square","type=large")
    end
    url
  end

  def mobile?
    browser.mobile?
  end
  def desktop?
    !mobile?
  end

  def last_login
    # return the date of the next-to-last new_session event (the last is the current session)
    Event.new_session.order("created_at desc")[1].try(:created_at) || Time.now
  end
  def last_login_string
    last_login.strftime("%d %b %y")
  end

  def heroku_base_url
    instance_name = ENV['HEROKU_INSTANCE_NAME']
    # raise "HEROKU_INSTANCE_NAME is not set in the environment" unless instance_name
    "https://#{instance_name}.herokuapp.com"
  end

  def google_fonts_link
    request.protocol + "fonts.googleapis.com/css?family=Open+Sans:400,300,600,700,800|Passion+One:400,700"
  end

  def week_date_string_for_action_plan(action_plan)
    week_date_string_for action_plan.created_at
  end

  def week_date_string_for_action_plan_with_year(action_plan)
    week_date_string_for(action_plan.created_at) + ", #{action_plan.created_at.year}"
  end

  def weekday_name_for(time)
    time.strftime("%A")
  end

  def theme_for_week(week_number)
    WEEK_THEMES[(week_number-1) % WEEK_THEMES.length]
  end

  def encouragement_salutation
    [
      "Keep it up",
      "Hooray",
      "You're on a roll",
      "Nice work",
    ].sample
  end

  def humorous_encouragement 
    [
      "Have you been working out? Your brain looks great!",
      "Are you trying to impress us? It's working!",
      "You are #WINNING.",
      "It's like you're perfect or something…",
      "Don't stop. Get it. Get it.",
      "We're so proud of you.",
      "Clearly you've been eating your spinach.",
      "Your radiance is blinding us.",
      "You must be going for the gold this week.",
      "You are learning well, young grasshopper.",
      "That's it!  Wax on.  Wax off! You've got it!",
      "Congratulations on being awesome.",
      "Congratulations on being so cool.",
      "Superman ain't got a thing on you!",
      "If this was a marathon, you'd be in 1st place.",
      "How does awesome feel?",
      "Be careful.  People might start to get ealous of your coolness.",
      "Could we have your signature? We're star struck.",
      "If only everyone was as good as you.",
      "Work it!",
      "You're the most determined human we know!",
      "To infinity, and beyond!",
      "That's the spirit!",
      "Go for the gold!",
      "Winner, winner, chicken dinner!",
      "Are you feeling lucky?",
      "Don't stop 'til you get enough!",
      "Does your head hurt? Your mind is getting HUGE!",
      "Don't mind us.  We're just admiring your assets.",
      "All you need is a crown, and you'll rule the world.",
      "How's it feel to be on top of the world?",
  ].sample
end

  private
  def week_date_string_for(start_t)
    end_t = start_t + 7.days
    from_string = start_t.strftime("%b %d-")
    if start_t.month == end_t.month
      to_string = end_t.strftime("%d")
    else
      to_string = end_t.strftime("%b %d")
    end
    from_string + to_string
  end

  def create_or_update_lead(email, params)
    lead = current_lead || Lead.where(email:email).first
    if lead.nil?
      params.merge!(email:email)
      if lead = Lead.create(params.merge(params))
        mixpanel_track('Captured Lead', params.merge(email:email))
        Resque.enqueue(UpdateMailChimp, email, :lead)
      else
        logger.warn "Couldn't create lead with params: #{params.to_yaml}"
      end
    end

    params.delete(:source) unless lead.source.nil?
    params.delete(:campaign) unless lead.campaign.nil?
    lead.update_attributes params.merge(email:email)

    session[:lead_id] = lead.id
    lead
  end

  # convert underscores to the conanical css class format with dashed
  def ruby_to_css_class(ruby_name)
    return "" unless ruby_name
    ruby_name.to_s.gsub('_','-')
  end
end
