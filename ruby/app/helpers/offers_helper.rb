module OffersHelper
  def plan_cost(plan)
    "#{plan_amount(plan)}/#{plan_interval(plan)}"
  end

  def plan_amount(plan)
    number_to_currency plan.amount.to_f/100
  end

  def plan_interval(plan)
    plan.interval_count == 1 ? plan.interval : "#{plan.interval_count} #{plan.interval.pluralize}"
  end
end
