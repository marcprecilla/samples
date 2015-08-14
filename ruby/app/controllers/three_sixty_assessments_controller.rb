class ThreeSixtyAssessmentsController < ApplicationController
  skip_before_filter :authenticate, only: [:new, :edit, :update]
  skip_before_filter :verify_subscription
	
 #  def new
 #    @window_title = '360 Assessment'
 #    @menu_section = 'toolkit'  # TODO ?
 #    @user = current_user

 #    @assessment = ThreeSixtyAssessment.find_unexpired_and_incomplete_assessment(current_enrollment, nil) || ThreeSixtyAssessment.new

 #    track_event(current_enrollment, :initiated_360_assessment,  {target:@assessment, subject_uuid:@user.uuid} )
	# end

 #  def show
  	
 #  end

  # here, the invitee visits to go through the assessment
  def edit
    assessment = ThreeSixtyAssessment.find_by_uuid(params[:id])
    raise "An assessment was not found" unless assessment

    @invitation_uuid = params[:invitation_uuid]
    invitation = Invitation.find_by_uuid @invitation_uuid
    @subject = invitation.sender

    @invitee_name = invitation.recipient_name
    @invitee_email = invitation.recipient

    # puts "INVITATION UUID: #{params[:invitation_uuid]}"
  	# @invitation = Invitation.find_by_uuid(params[:invitation_uuid])
    # @subject = @invitation.sender

    # puts "SUBJECT: #{@subject}"

    # TODO Chris: update this via params as necessary
    # @recipient_identifier = params[:recipient] || @invitation.recipient
    # puts "recipient_identifier: #{@recipient_identifier}"

  	# subject_enrollment = @subject.current_enrollment


  	# @window_title = '360 Assessment'
    # @menu_section = 'toolkit'  # TODO ?

    # mixpanel_track( 'Taking 360 Assessment', {} )

    # @assessment = ThreeSixtyAssessment.find_unexpired_and_incomplete_assessment(subject_enrollment, @recipient_identifier)
    

    # Can't track as a normal event until Event is updated to support leads correctly (there is no uuid on an Event and this is currently causing a problem)
    #mixpanel_track( 'Taking 360 Assessment', {subject_uuid:@subject.uuid, recipient_identifier:invitation.recipient, recipient_type:invitation.recipient_type} )
    if current_enrollment
      track_event(current_enrollment, :taking_360_assessment, { target:assessment, subject_uuid:@subject.uuid, recipient_identifier:invitation.recipient, recipient_type:invitation.recipient_type} )
    else
      mixpanel_track( 'Taking 360 Assessment', {subject_uuid:@subject.uuid, recipient_identifier:invitation.recipient, recipient_type:invitation.recipient_type} )
    end

    @assessment = assessment
    @questions = assessment.unanswered_checks_for(@invitation)
  end

  # process the invitee's assessment of the subject
  def update
    raise "need to provide the 'invitation_uuid' param" unless params[:invitation_uuid]
    raise "need to provide the 'answers' param" unless params[:answers]
    raise "need to provide the 'ways_to_communicate' param" unless params[:ways_to_communicate]
    raise "need to provide the 'good_times' param" unless params[:good_times]

    # "answers"=>{"2e6ef486-71da-4a55-a964-bc3d35b68905"=>"", "6998baeb-8137-46bf-a19c-203516e46f48"=>"", "bba75480-701b-4bca-bbd4-f9a26837897f"=>""}, 
    # "ways_to_communicate"=>"person phone text social email", 
    # "invitation_uuid"=>"4fc4d329-be71-48bd-b318-d1dbfcff4533", 
    # "good_times"=>"", 
    # "id"=>"7228a166-b7fd-44d5-bef5-3473c9c44080"}

    invitation = Invitation.find_by_uuid(params[:invitation_uuid])
    subject = invitation.sender
    raise "Couldn't find the subject user" unless subject
    subject_enrollment = subject.current_enrollment

    assessment = ThreeSixtyAssessment.find_unexpired_and_incomplete_assessment(subject_enrollment, invitation.recipient)
    raise "Couldn't find the assessment for enrollment uuid #{@subject.enrollment_uuid} and recipient_identifier #{invitation.recipient_identifier}" unless assessment

    # just stored as a list of the symbol values.  See: ThreeSixtyAssessment.WAYS_TO_COMMUNICATE
    ways_to_communicate = params[:ways_to_communicate]
    good_times = params[:good_times]

    if  sup = assessment.supplimental_answers.where(respondent_identifier:invitation.recipient).last
      sup.update_attributes!(ways_to_communicate:ways_to_communicate, good_times:good_times)
    else
      assessment.supplimental_answers.create!(respondent_identifier:invitation.recipient, ways_to_communicate:ways_to_communicate, good_times:good_times)
    end


    params[:answers].each do |question_uuid, answer|
      logger.info " ANSWER:  question_uuid:#{question_uuid}    answer:#{answer}"
      # next if answer == "" # bypass enpty answers

      check = Check.find_by_uuid(question_uuid)
      throw "you must provide the uuid of the question (aka check)" unless check

      assessment.responses.create!(check_uuid:check.uuid, value:answer, respondent_identifier:invitation.recipient)
    end

    # if we get here, then the assessment must be complete (right now, exceptions are thrown)
    track_event(current_enrollment, :completed_360_assessment,  target:assessment)
    render text:"ok"
  rescue Exception => e
    logger.error("THREE SIXTY ERROR: #{e.message}")
    raise e  # TODO remove the raise when dev is stable
    #render text:"Error: #{e.message}"
  end

end
