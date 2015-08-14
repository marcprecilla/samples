require 'csv'
class Marketing::MarketingBaseController < ApplicationController
  http_basic_authenticate_with name: 'lex', password: 'titssp4m'
  skip_before_filter :authenticate, :accept_terms, :check_for_interstitials, :complete_onboarding, :verify_subscription, :capture_common_session_vars
  
  before_filter :filter_params, only: :index

  respond_to :html, :csv

  def index_attributes
    raise "index_attributes must be defined in the subclass"
  end

  def index
    @report_name = report_name

    @from = params[:from] ? params[:from].to_i : 0
    @to = params[:to] ? params[:to].to_i : 0
    @limit = params[:limit] ? params[:limit].to_i : 10
    @offset = params[:offset] ? params[:offset].to_i : 0

    index_attributes
    
    flash[:notice]= "From #{@from} days ago to #{@to} days ago with a limit of #{@limit} and offset of #{@offset}"

    respond_to do |format|
      format.html
      format.csv { generate_csv_headers("#{report_name}-#{Time.now.strftime("%Y%m%d")}") }
    end

  end

  private 

  def report_name
    self.class.name.sub('Marketing::','').sub('Controller','') + 'Report'
  end

  def filter_params
    @from = params[:from] ? params[:from].to_i : 0
    @to = params[:to] ? params[:to].to_i : 0
    @limit = params[:limit] ? params[:limit].to_i : 10
    @offset = params[:offset] ? params[:offset].to_i : 0
  end

  def generate_csv_headers(filename)
    headers.merge!({
      'Cache-Control'             => 'must-revalidate, post-check=0, pre-check=0',
      'Content-Type'              => 'text/csv',
      'Content-Disposition'       => "attachment; filename=\"#{filename}\"",
      'Content-Transfer-Encoding' => 'binary'
    })
  end

end
