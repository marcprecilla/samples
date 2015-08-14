class Marketing::ChargesController < Marketing::MarketingBaseController

	include StripeHelper

  def index_attributes
  	logger.info "fetching Stripe charges..."
    @charges = @from == 0 ? [] : Marketing::Charge.all(@from.days.ago, @to.days.ago, @limit, @offset)
		logger.info "  ..fin."

    @csv_header = CSV.generate_line Marketing::Charge.csv_header_array
  end

  private

  def report_name
    self.class.name.sub('Marketing::','').sub('Controller','')
  end

end
