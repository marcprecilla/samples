class AboutController < ApplicationController
  skip_before_filter :authenticate, :verify_subscription, :accept_terms

  def index
    @menu_section = 'about'

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end
  end

end
