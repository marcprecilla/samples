class Marketing::LeadsController < Marketing::MarketingBaseController
  
  def index_attributes
    @rows = @leads = Lead.where(created_at:[@from.days.ago..@to.days.ago]).limit(@limit).offset(@offset)
    @csv_header = Lead.csv_header_array
  end

end
