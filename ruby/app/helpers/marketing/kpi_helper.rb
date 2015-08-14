module Marketing::KpiHelper

   # * Unique Visitors
   # * New Leads
   # * Sales
   # * Revenue
   # * Engagment (% of logins)
   # * Word of Mouth (% of social shares relative to number of users)
   # * Efficacy (PSS baseline versus subsequent checkins.)
  KpiRow = Struct.new(
    :visitors, :conversion_rate, :paid_users, :revenue, 
    :avg_monthly_price_per_user, :avg_time_on_site, :virality, :viral_coefficient, :engagement_percent)

  def unique_visitors(from, to)
    enrollment_visit_count = Event.where(created_at:from..to, type: :page_view).uniq_by(&:enrollment_uuid).count
    lead_visit_count = Event.where(created_at:from..to, type: :page_view).uniq_by(&:lead_uuid).count
  end

  def new_leads(from, to)
    Lead.where(created_at:from..to).count
  end

  def sales(from, to)
    Event.where(created_at:from..to, type: :sale).count
  end

  def revenue(from, to)
    Event.where(created_at:from..to, type: :sale).collect{|e|e.data.to_f}.reduce(:+)
  end

  def engagment(from, to)
    rand(40)+20
  end

  def word_of_mouth(from, to)
    rand(40)+20
  end

  def efficacy(from, to)
    rand(40)+20
  end

end








