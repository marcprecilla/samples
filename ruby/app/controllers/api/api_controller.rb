class Api::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate

  skip_before_filter :require_ssl
  skip_before_filter :verify_subscription
  skip_before_filter :accept_terms
  skip_before_filter :check_for_interstitials
  skip_before_filter :complete_onboarding
  skip_before_filter :capture_common_session_vars

  before_filter :authenticate_api

private
  
  def authenticate_api
    # todo: ensure caller is authenticated
  end
end
