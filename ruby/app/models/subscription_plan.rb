class SubscriptionPlan < ActiveRecord::Base
  include UUIDRecord
  include ActionView::Helpers::NumberHelper

  attr_accessible :active, :name, :plan_description, :price_description, :recurring, :stripe_plan_id, :trial_period, :uuid

  validates :name, presence: true
  # validates :price_description, presence: true
  validates :stripe_plan_id, presence: true
  validates :recurring, inclusion: [true, false]
  validates :active, inclusion: [true, false]

  belongs_to :offer, primary_key: 'uuid', foreign_key: 'offer_uuid'

  after_initialize :set_defaults

  def set_defaults
    self.active = true if self.active.nil?
    self.recurring = true if self.recurring.nil?
  end

  def best_value?
    self.uuid == self.offer.best_value_plan_uuid
  end

  def stripe_plan
    @stripe_plan ||= Stripe::Plan.retrieve(self.stripe_plan_id)
  end

  def name
    read_attribute(:name) || self.stripe_plan.name
  end

  def apply_coupon(coupon)
    return nil unless coupon

    case coupon.duration
    when 'once'
      @coupon = coupon unless self.recurring
    when 'repeating', 'forever'
      @coupon = coupon if self.recurring
    end

    @coupon
  end

  def price
    (self.stripe_plan.amount / 100.0).round(2)
  end

  def price_per_month
    plan = self.stripe_plan

    case plan.interval
    when 'week'
      cents = plan.amount.to_f * (52 / plan.interval_count / 12)
    when 'month'
      cents = plan.amount.to_f / plan.interval_count
    when 'year'
      cents = plan.amount.to_f / (12 * plan.interval_count)
    end

    (cents / 100.0).round(2)
  end

  def discounted_price
    return self.price unless @coupon

    case
    when @coupon.percent_off
      discount = self.stripe_plan.amount * @coupon.percent_off / 100.0
    when @coupon.amount_off
      discount = @coupon.amount_off
    end

    (stripe_plan.amount - discount) / 100.0
  end

  def term
    plan = self.stripe_plan

    if plan.interval_count == 1
      case plan.interval
      when 'week'
        'Weekly Subscription'
      when 'month'
        'Monthly Subscription'
      when 'year'
        'Yearly Subscription'
      end
    else
      "x #{plan.interval_count} #{plan.interval.pluralize}"
    end
  end

  def description
    # read_attribute(:plan_description)

    case
    when self.recurring
      case stripe_plan.interval_count
      when 1
        "a #{stripe_plan.interval}. Cancel anytime."
      else
        "every #{stripe_plan.interval_count} #{stripe_plan.interval.pluralize}."
      end
    else
      case stripe_plan.interval_count
      when 1
        "for 1 #{stripe_plan.interval}."
      else
        "for #{stripe_plan.interval_count} #{stripe_plan.interval.pluralize}."
      end
    end
  end

  def price_description
    read_attribute(:price_description)
  end


  # Coupon discounts
  def discount_description
    return nil unless @coupon

    case
    when @coupon.percent_off
      discount = number_to_percentage(@coupon.percent_off, precision: 0)
    when @coupon.amount_off
      discount = number_to_currency(@coupon.amount_off / 100.0)
    end

    case @coupon.duration
    when 'once'
      "Save #{discount}."
    when 'repeating'
      "Save #{discount} a month for #{@coupon.duration_in_months} months."
    when 'forever'
      "Save #{discount}."
    end
  end

  # Discount relative to best plan of the default offer
  def discount_from_default_plan
    default_price = Offer.where(default:true).first.best_value_plan.price_per_month
    this_price = price_per_month
    100 - (100.0*(this_price/default_price.to_f)).to_i
  end



end
