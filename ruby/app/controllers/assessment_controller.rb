class AssessmentController < ApplicationController
  include BigFiveAssessmentHelper
  include BenefitAssessmentHelper

  skip_before_filter :authenticate
  skip_before_filter :verify_subscription
  skip_before_filter :complete_onboarding
  skip_before_filter :accept_terms

  before_filter :find_assessment, only: [:index]

  def index
    @window_title = 'Brain Builder'
    @menu_section = 'toolkit'
    @user = current_user

    @big_five_questions = []

    mixpanel_track( 'Started Prepaywall Assessment', {type: params[:np].nil? ? 'personality & benefits' : 'benefits' } )
    # curr_ai = current_action_item(BigFiveAssessmentHelper::COMPONENT_TYPE)
    # track_event(curr_ai||current_enrollment, :started_prepaywall_assessment, {type:'personality & benefits'} )

    @big_five_questions = Check.big5
    raise "NO QUESTIONS" unless @big_five_questions and @big_five_questions.count > 0

    @benefits_questions = BenefitAssessmentHelper::BENEFITS_QUESTIONS
  end

  def show
    assessment_uuid = session.delete(:assessment_uuid)
    puts "CONTROLLER: found assessment in session: #{assessment_uuid}"
    assessment_uuid = params[:id] if params[:id]

    @menu_section = 'toolkit'
    @enrollment = current_enrollment

    @assessment = PrePaywallAssessment.where(uuid:assessment_uuid).first
    @assessment = PrePaywallAssessment.where(enrollment_uuid:@enrollment.uuid).first if @assessment.nil? && @enrollment

    redirect_to assessment_index_path and return if @assessment.nil?

    @results = @assessment.results

    if @results && @results.any?
      @factor_1 = @results[0][:symbol]
      @factor_1_score = @results[0][:name]
      @factor_1_description = @results[0][:description]

      @factor_2 = @results[1][:symbol]
      @factor_2_score = @results[1][:name]
      @factor_2_description = @results[1][:description]

      @factor_3 = @results[2][:symbol]
      @factor_3_score = @results[2][:name]
      @factor_3_description = @results[2][:description]

      @factor_4 = @results[3][:symbol]
      @factor_4_score = @results[3][:name]
      @factor_4_description = @results[3][:description]

      @factor_5 = @results[4][:symbol]
      @factor_5_score = @results[4][:name]
      @factor_5_description = @results[4][:description]
    end

    @benefit_score = @assessment.benefits_score
    @benefit1, @benefit2 = @benefit_score.sort_by {|k,v| v }.collect(&:first)[0..1].collect {|s| title_for_benefit s}

    mixpanel_track( 'Viewed Prepaywall Assessment Results', {type: @results.nil? ? 'benefits' : 'personality & benefits' } )
    # curr_ai = current_action_item(BigFiveAssessmentHelper::COMPONENT_TYPE)
    # track_event(curr_ai||current_enrollment, :viewed_prepaywall_assessment_results, {type:'personality & benefits'} )

    render :show_without_personality if @results.nil?
  end

  def create
    raise "assessment/create: [demographics] must exist in params" unless params[:demographics]
    raise "assessment/create: [demographics][date_of_birth] must exist in params" unless params[:demographics][:date_of_birth]
    raise "assessment/create: [demographics][gender] must exist in params" unless params[:demographics][:gender]
    raise "assessment/create: [demographics][relationship_status] must exist in params" unless params[:demographics][:relationship_status]
    raise "assessment/create: [name] must exist in params" unless params[:name]

    assessment = PrePaywallAssessment.new(enrollment_uuid:current_enrollment ? current_enrollment.uuid : nil)

    assessment.benefits_hash = params[:assessment] ? params[:assessment][:benefits] : {}
    assessment.save!
    create_answers(assessment)

    session[:assessment_uuid] = assessment.uuid

    @score = assessment.score

    name  = params[:name]
    gender = params[:demographics][:gender]
    relationship_status = params[:demographics][:relationship_status]

    date_of_birth = params[:demographics][:date_of_birth]
    date_string = "#{date_of_birth['day']}-#{date_of_birth['month']}-#{date_of_birth['year']}"
    date_of_birth = Date.parse(date_string)

    if user = current_user
      user.update_attributes(name:name, date_of_birth:date_of_birth, relationship_status:relationship_status)
      puts " - user exists, updating."
    else
      # store the demographic info for use in the update call
      session[:lead_info] = {name:name,  assessment_uuid:assessment.uuid, gender:gender, relationship_status:relationship_status, date_of_birth:date_of_birth}
      puts " - stashed lead information: #{session[:lead_info].to_yaml}"
    end

    mixpanel_track( 'Completed Prepaywall Assessment', {assessment_uuid:assessment.uuid, name:name,  assessment_uuid:assessment.uuid, gender:gender, relationship_status:relationship_status, date_of_birth:date_of_birth } )
    # curr_ai = current_action_item(BigFiveAssessmentHelper::COMPONENT_TYPE)
    # track_event(curr_ai||current_enrollment, :completed_prepaywall_assessment, {assessment_uuid:assessment.uuid, name:name, assessment_uuid:assessment.uuid, gender:gender, relationship_status:relationship_status, date_of_birth:date_of_birth } )


    puts " - fin create"
    redirect_to assessment_path(assessment)
  end

  def update
    puts "called assessment/update"
    puts "  email: #{params[:email]}"
    puts "  lead_info: #{session[:lead_info]}"

    assessment = PrePaywallAssessment.where(uuid:params[:id]).first

    # gather name and email
    name = params[:name]
    email = params[:email]

    if email.nil? && current_user
      puts " - no email in params, grabbing it from current_user"

      email = current_user.email
    end

    if name.nil? && current_user
      puts " - no name in params, grabbing it from current_user"
      name = current_user.first_name
      email = current_user.email unless email
    # elsif name.nil? && lead_info = session.delete(:lead_info)
    elsif name.nil? && lead_info = session[:lead_info]
      # remove unused demographic info
      puts " - no name in params, grabbing it from session lead_info"
      # lead_info.delete :date_of_birth
      # lead_info.delete :relationship_status
      # lead_info.delete :gender

      # we have an email now, pull the demographic information from the session and use it and the email to create a lead
      lead = create_or_update_lead(params[:email], lead_info)
      name = lead.name
    else
      puts "assessment/update ERROR: assessment/update: cannot find the user's name"
      name = ""
    end

    puts "Sending Results to #{name} at #{email}"

    Resque.enqueue(SendAssessmentResultsEmail, assessment.uuid, name, email, session)

    puts " - fin update."
    render text:"success".to_json
  rescue => e
    puts " - error!!! #{e.message}"
    render text:"error".to_json
  end

private

  def create_answers(assessment)
    return unless params[:answers]

    params[:answers].each do |question_uuid, answer|
      check = Check.find_by_uuid(question_uuid)
      throw "you must provide the uuid of the question (aka check)" unless check

      assessment.responses.create!(check_uuid:check.uuid, value:answer)
    end
  end

  def find_assessment
    # if there is an assessment that hasn't been seen, then the :assessment_uuid session var will be set.
    # in this case, we should go to the assessment
    if assessment = Assessment.find_by_uuid(session.delete(:assessment_uuid))
      puts "user has never seen the assessment results... go to results"
      redirect_to assessment_path(assessment)

    # if there is an assessment, but it hasn't been seen in a while, then go to the assessment results.
    # but if is has been seen recently, then bypass and go to the paywall
    elsif assessment = current_lead.try(:assessment)
      # in this case, there is an assessment, but it has been seen, so go to the subscription path instead
      if assessment.created_at > 30.minutes.ago # i.e. created "recently"
        puts "recent assessment... go to paywall"
        redirect_to subscriptions_path
      else
        puts "older assessment... sent the visitor to the results"
        redirect_to assessment_path(assessment)
      end
    else
      puts "no assessment, user or lead... start the assessment"
      # redirect_to assessment_index_path
    end
  end
end
