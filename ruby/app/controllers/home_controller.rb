class HomeController < ApplicationController
  skip_before_filter :require_ssl, only: [:index, :faq, :no_ie]
  skip_before_filter :authenticate, only: [:index, :faq, :no_ie]
  skip_before_filter :verify_subscription, only: [:index, :faq, :no_ie]
  skip_before_filter :complete_onboarding

  def index
    if current_user
      log "I'm at the home controller and a user exists, so I am redirecting to their action plan"
      redirect_to action_plan_index_path
    else
      # 2.12.14 gh: I'm changing this from the login path to the registration path 
      #   to support the 'new user' flow.
      log "I'm at the home controller and there is no user in session, so I am redirecting to the registration page"
      redirect_to registration_path
    end
  end

  def faq
    @menu_section = 'faq'

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end
  end

  def no_ie
    render :layout => "layouts/pages"
  end


end
