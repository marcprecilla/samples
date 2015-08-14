class InviteController < ApplicationController
  skip_before_filter :verify_subscription

  def new
    @user = current_user
    @invitesrc = "settingsinvite"
    if params[:invitesrc]
      @invitesrc = params[:invitesrc]
    end

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

    # @menu_section = 'invite'  # todo: for sidebar
  end

  def create # an invite
    redirect_to action_plan_index_path
  end

end
