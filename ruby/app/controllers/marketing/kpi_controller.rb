require 'marketing/kpi_helper'
class Marketing::KpiController < Marketing::MarketingBaseController
	include Marketing::KpiHelper

  def index_attributes
    @rows = [
    	KpiRow.new(54, 1.2, 45, 130.05, 25.50, 3.50, 5, 0.80, 45),
    	KpiRow.new(54, 1.2, 45, 130.05, 25.50, 3.50, 5, 0.80, 45),
    ]
    @csv_header = "TODO"
  end

end
