require 'mandrill'
include BigFiveAssessmentHelper
include BenefitAssessmentHelper
include StressLessEmailHelper

class SendAssessmentResultsEmail

  @queue = :normal
  
  def self.perform(assessment_uuid, name, email, params)
    puts "AssessmentResultsEmail for plan: #{assessment_uuid}"
  
    assessment = Assessment.find_by_uuid(assessment_uuid)
    Rails.logger.error("Dev error #67497: Invalid assessment id for the assessment results email") and return unless assessment
    results = assessment.results  
  
    # see if we have an image
    user = assessment.enrollment ? assessment.enrollment.user : nil
    user = User.find_by_uuid(user.uuid) if user && user.email.nil?
    profile_image_url = user.try(:profile_image_url)
    
    benefits_score = assessment.benefits_score
    benefit1, benefit2 = benefits_score.sort_by {|k,v| v }.collect(&:first)[0..1].collect {|s| title_for_benefit s}
  
    week = 1 # always
    action_plan_content = EMAIL_CONTENT[week-1]
    puts action_plan_content.to_yaml
    
    # message = "Message here"#StressLessEmailHelper::message_text(week)
    subject = "Your app Assessment Results"#StressLessEmailHelper::subject(week)
  
    action_plan = assessment.enrollment ? assessment.enrollment.action_plans.last : nil
    action_plan_content.merge!(intervention_info)

    link_params_string = generate_link_parameters(source:params[:source], campaign:params[:campaign], landing_page:params[:landing_page])

    puts "AssessmentResultsEmail: '#{email}', name: '#{name}' "
    puts "AssessmentResultsEmail.before Mandrill.new"
  
    m = Mandrill::API.new
    message = {
          subject: subject,
          from_email: 'no-reply@myapp.com',
          from_name: 'app Team',
          #to: users.collect {|u| {email: u.email, name: u.name}},
          to:  [{email: email, name: name}],
          track_opens: true,
          track_clicks: true,
          url_strip_qs: true,
          preserve_recipients: false,
          global_merge_vars: [
            {name: 'FNAME', content: name.try(:upcase)},
            {name: 'DAY', content: week},
            {name: 'DAY', content: week},
            {name: 'SUBJECT', content: subject},
            {name: 'LINK_PARAMS', content: link_params_string},
  
            {name: 'BENEFIT_1', content: benefit1},
            {name: 'BENEFIT_2', content: benefit2},
  
            {name: 'FOCUS_SCORE', content: benefits_score[:focus]},
            {name: 'POSITIVITY_SCORE', content: benefits_score[:positivity]},
            {name: 'SLEEP_SCORE', content: benefits_score[:sleep]},
            {name: 'SOCIAL_SCORE', content: benefits_score[:social]},
  
            {name: 'FACTOR_1_SYM', content: results ? results[0][:symbol].to_s : nil},
            {name: 'FACTOR_1_NAME', content: results ? results[0][:name] : nil},
            {name: 'FACTOR_1_DESCRIPTION', content: results ? results[0][:description] : nil},
  
            {name: 'FACTOR_2_SYM', content: results ? results[1][:symbol].to_s : nil},
            {name: 'FACTOR_2_NAME', content: results ? results[1][:name] : nil},
            {name: 'FACTOR_2_DESCRIPTION', content: results ? results[1][:description] : nil},
  
            {name: 'FACTOR_3_SYM', content: results ? results[2][:symbol].to_s : nil},
            {name: 'FACTOR_3_NAME', content: results ? results[2][:name] : nil},
            {name: 'FACTOR_3_DESCRIPTION', content: results ? results[2][:description] : nil},
  
            {name: 'FACTOR_4_SYM', content: results ? results[3][:symbol].to_s : nil},
            {name: 'FACTOR_4_NAME', content: results ? results[3][:name] : nil},
            {name: 'FACTOR_4_DESCRIPTION', content: results ? results[3][:description] : nil},
  
            {name: 'FACTOR_5_SYM', content: results ? results[4][:symbol].to_s : nil},
            {name: 'FACTOR_5_NAME', content: results ? results[4][:name] : nil},
            {name: 'FACTOR_5_DESCRIPTION', content: results ? results[4][:description] : nil},
            
            {name: 'INTERVENTION_1_IMAGE_URL', content: action_plan_content[:intervention_1_image_url].to_s},
            {name: 'INTERVENTION_1_NAME', content: action_plan_content[:intervention_1_name]},
            {name: 'INTERVENTION_1_APPROPRIATE_TIME', content: action_plan_content[:intervention_1_appropriate_time]},
            {name: 'INTERVENTION_1_DURATION', content: action_plan_content[:intervention_1_duration]},
            {name: 'INTERVENTION_1_AREA', content: action_plan_content[:intervention_1_area]},
            {name: 'INTERVENTION_1_URL', content: action_plan_content[:intervention_1_url]+"?#{link_params_string}"},
  
            {name: 'INTERVENTION_2_IMAGE_URL', content: action_plan_content[:intervention_2_image_url].to_s},
            {name: 'INTERVENTION_2_NAME', content: action_plan_content[:intervention_2_name]},
            {name: 'INTERVENTION_2_APPROPRIATE_TIME', content: action_plan_content[:intervention_2_appropriate_time]},
            {name: 'INTERVENTION_2_DURATION', content: action_plan_content[:intervention_2_duration]},
            {name: 'INTERVENTION_2_AREA', content: action_plan_content[:intervention_2_area]},
            {name: 'INTERVENTION_2_URL', content: action_plan_content[:intervention_2_url]+"?#{link_params_string}"},
  
            {name: 'INTERVENTION_3_IMAGE_URL', content: action_plan_content[:intervention_3_image_url].to_s},
            {name: 'INTERVENTION_3_NAME', content: action_plan_content[:intervention_3_name]},
            {name: 'INTERVENTION_3_APPROPRIATE_TIME', content: action_plan_content[:intervention_3_appropriate_time]},
            {name: 'INTERVENTION_3_DURATION', content: action_plan_content[:intervention_3_duration]},
            {name: 'INTERVENTION_3_AREA', content: action_plan_content[:intervention_3_area]},
            {name: 'INTERVENTION_3_URL', content: action_plan_content[:intervention_3_url]+"?#{link_params_string}"},

            {name: 'SOURCE', content: params[:source]},
            {name: 'CAMPAIGN', content: params[:campaign]},
            {name: 'LANDING_PAGE', content: params[:landing_page]},
          ],
          merge_vars: [
          {
            rcpt: email,
            vars:[
              {name: 'PROFILE_URL', content: profile_image_url},
              {name: 'EMAIL', content: email}, 
              {name: 'UNSUBSCRIBE', content: self.unsubscribe_url(email)}
            ]
          }],
          google_analytics_domains: GA_DOMAINS,
          google_analytics_campaign: "sl_week_#{week}"
    }
    puts "AssessmentResultsEmail.before send with #{message.to_yaml}"
  
    mandrill_template =  assessment.include_personality? ? 'stressless-results-notification' : 'stressless-results-notification-without-personality-results'
    results = m.messages.send_template(mandrill_template, [], message)
    puts "Mandrill results: #{results.inspect}"
  end

  def self.start_url
    Rails.application.routes.url_helpers.dashboard_url(protocol: PROTOCOL, host: HOST)
  end

  def self.unsubscribe_url(email)
    Rails.application.routes.url_helpers.unsubscribe_url(protocol: PROTOCOL, host: HOST, email: email)
  end

  def self.intervention_url(key)
    "http://train.myapp.com/activity/new/#{key}"
  end

  def self.intervention_image_url(key)
    key = key.to_s.gsub("_","-")
    "http://s3.myapp.com/stressless/email/email.stressless.int.#{key}.gif"
  end

  def self.intervention_info
      data = {}      
      [:savoring_album_sight, :diaphragmatic_breathing, :thank_bank_work].each_with_index do |key,i|
        intervention = Intervention.where(key:key).first

        data["intervention_#{i+1}_url".to_sym] =  intervention_url(intervention.key) 
        data["intervention_#{i+1}_image_url".to_sym] =  intervention_image_url(intervention.key) #"http://s3.myapp.com/stressless/email/email.stressless.intervention.sight.gif"
        data["intervention_#{i+1}_name".to_sym] =  intervention.name
        data["intervention_#{i+1}_appropriate_time".to_sym] =  intervention.setting.titlecase
        data["intervention_#{i+1}_duration".to_sym] = intervention.duration
        data["intervention_#{i+1}_area".to_sym] = InterventionHelper::category_for_intervention_sym(intervention.key) #"Focus",
      end
      data
  end

end
