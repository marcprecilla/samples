class InvitationsController < ApplicationController
  skip_before_filter :authenticate, only: [:show]
  skip_before_filter :verify_subscription

  # show all invitations that a user has sent
  def index
    case params[:invitation_type].try(:to_sym)
    when :three_sixty
      @email_invitations = Invitation.where(sender_uuid: current_user.uuid, recipient_type: 'email')
    else
      @email_invitations = []
    end

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end


  end

  # respond to a sent invitation
  def show
    @invitation = Invitation.find_by_uuid(params[:id])
    @subject = @invitation.sender

    @invitee_name = @invitation.recipient_name
    @invitee_email = @invitation.recipient
  end

  def create
    assessment = ThreeSixtyAssessment.find_unexpired_and_incomplete_assessment(current_enrollment, nil)

    # raise "Could not find a 360 assessment - this shouldn't occur - debug me" unless assessment
    # Update 1/23/14 gh: requirements have change a few times, to I'm going to just create a 360 assessment if it doesn't exist. This will also help with backwards compatability.
    unless assessment
      baseline_assessment = current_enrollment.assessments.baseline.last
      assert baseline_assessment, "Developer error: Cannot find a baseline assessment, but we are trying to create a 360 assessment."
      
      assessment = ThreeSixtyAssessment.create!(enrollment_uuid:current_enrollment.uuid, baseline_assessment_uuid:baseline_assessment.uuid)
    end

    @invite = Invitation.new(params.slice(:recipient_name, :recipient, :recipient_type))
    @invite.sender_uuid = current_user.uuid
    @invite.subject_type = 'three_sixty_assessment'
    @invite.subject = assessment.uuid

    if @invite.save
      Resque.enqueue(SendThreeSixtyEmail, @invite.uuid)
      render 'create'

      track_event(current_enrollment, :invitation_for_360_assessment,  target:@invite, subject_uuid:current_user.uuid, recipient_name:@invite.recipient_name, recipient_identifier:@invite.recipient, recipient_type:@invite.recipient_type)
    else
      render 'error'
    end

    # for invitee in params[:invitees]
    #   logger.info invitee.to_yaml
    #   invitation_method = "email"
    #   invitation_method = "mobile_number" if invitee[:sms].present?
    #   invitation_method = "facebook_id" if invitee[:facebook_id].present? # todo chris: how do we recognize a facebook type

    #   @invitation = Invitation.create!(sender_uuid: current_user.uuid, subject_type:params[:subject_type], recipient:invitee[:email]||invitee[:mobile_number]||invitee[:facebook_id], recipient_name:invitee[:name], recipient_type: invitation_method)
    # end

    # # TODO Chris: send

    # redirect_to params[:redirect_path]
  end
end
