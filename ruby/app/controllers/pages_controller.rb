class PagesController < ApplicationController
  skip_before_filter :require_ssl, :authenticate, :accept_terms, :complete_onboarding, :capture_common_session_vars

  before_filter :set_cache_buster, :only => 'fb_channel'

  def fb_channel

    render :layout => false
  end

  def paywall
    render :layout => "layouts/pages"
  end

  def payment_confirmation
    render :layout => "layouts/pages"
  end

end
