class Marketing::LifetimeValueController < Marketing::MarketingBaseController

	LtvRow = Struct.new(
		:visitors, :conversion_rate, :paid_users, :revenue, 
		:avg_monthly_price_per_user, :avg_time_on_site, :virality, :viral_coefficient, :engagement_percent)

  def index_attributes
    @rows = [] #@charges = @from == 0 ? [] : Marketing::Charge.all(@from.days.ago, @to.days.ago, @limit, @offset)
		@csv_header = "TODO"
  end

end
