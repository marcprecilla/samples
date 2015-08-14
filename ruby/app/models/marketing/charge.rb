
# > c=Marketing::Charge.all(7.days.ago, 3.days.ago,1).first
#  => #<Marketing::Charge:0x00
# > c.email
#  => "garrett+ffass@appinc.com" 
# > c.plan_id
#  => "quarterly_3995" 
# > c.user
#  => #<User id: 3, ...> 
# > c.user_first_name
#  => "Bobby" 

class Marketing::Charge

  def self.all(from, to, limit=100, offset=0)
    Stripe::Charge.all(count:limit, offset:offset, created:{gte:from.to_i, lte:to.to_i}).collect{|c| Marketing::Charge.new(c)}
  end

  def self.find_user(email)
    ::User.find_by_email(email)
  end

  attr_reader :user, :stripe_charge, :customer, :plan
  
  delegate :email, :subscription, to: :customer, allow_nil:true
  delegate :plan, :plan_id, to: :subscription, allow_nil:true
  delegate :id, to: :plan, prefix: true, allow_nil:true

  delegate :first_name, :last_name, :age_demographic, to: :user, prefix: true, allow_nil:true
  delegate :source, :campaign, :landing_page, to: :user, prefix: false, allow_nil:true

  def customer
    @customer ||= Stripe::Customer.retrieve(@stripe_charge.customer)
  end

  def initialize(stripe_charge)
      @stripe_charge = stripe_charge
      @user = Marketing::Charge.find_user(email) if @stripe_charge
  end

  def created_at
    Time.at(stripe_charge.created)
  end

  def self.csv_header_array
    ['Email', 'Plan', 'Created', 'First Name', 'Last Name', 'Age', 'Source', 'Campaign', 'Landing Page']
  end
  def csv_row_array
    [email, plan_id, created_at.strftime("%d %b %y"), user_first_name, user_last_name, user_age_demographic, source, campaign, landing_page]  
  end
end

