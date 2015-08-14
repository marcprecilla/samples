class CheckinsController < ApplicationController
  include CheckinsHelper

  def new
    @menu_section = 'checkin'

    # todo: utilize parameters for week & day to adjust action plan accordingly

    if day = params[:day]
      log "UNSKIPPING CHECKINS FOR DAY #{day}"
      for check in current_action_plan.action_items.for_day(day).checks
        check.unskip! if check.skipped?
      end
    end

    action_items = current_action_plan.unanswered_check_in_questions

    # if there are no action items at this point, it means that they are complete.  So generate "extra credit" items.
    # note that this will allow a user to accumulate points quickly.  Not at issue right now, but if points become meaningful, 
    # then we should limit the allowed checkins (only on per day or something.)
    if action_items.empty?
      log "creating extra credit checkin AIs for day #{day}"
      current_action_plan.create_check_in_action_items(day, false)
      action_items = current_action_plan.unanswered_check_in_questions
    end

    @questions = action_items.collect{|ai| ai.check}  # if this is nil that db data is bad.
    @window_title = "app Check-In"

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

  end

  def create
    throw "need to provide 'answers' param (just like the other assessment)" unless params[:answers]

    answers = params[:answers]
    @action_plan = current_action_plan

    assessment = current_action_plan.checkin_assessment

    answers.each do |question_uuid, answer|
      check = Check.find_by_uuid(question_uuid)
      throw "you must provide the uuid of the question (aka check)" unless check

      Response.create!(assessment_uuid:assessment.uuid, check_uuid:check.uuid, value:answer)
    end

    points = ANSWER_ASSESSMENT_QUESTION_POINTS * answers.count

    # TODO: there are multiple action items :(
    track_event(current_action_item(Check::COMPONENT_TYPE)||current_enrollment, :checkin,  target:assessment, points:points, number_of_questions:answers.count)

    # TODO: prob should go to a filter, or be decided at the destination (the progress screen)
    # if it's after two weeks, then go to progress(trends), else just go to progress()
    if desktop?
      render nothing:true
    elsif  trends_are_available?  # earlier than two weeks
      redirect_to progress_path(mode: :trends)
    else
      redirect_to progress_path
    end
  end

end
