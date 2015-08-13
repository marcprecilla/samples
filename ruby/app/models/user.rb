require 'bcrypt'

class User < ActiveRecord::Base
  include UUIDRecord

  scope :subscribed, where("subscription_plan_uuid IS NOT NULL")

  attr_accessible :uuid, :children, :relationship_status, :workplace_environment, :home_environment, :profile_image_url,
    :age_demographic, :receive_email_notifications, :terms_accepted_on, :email, :password, :password_confirmation,
    :date_of_birth, :facebook_identifier, :facebook_photo_album_id, :first_name, :gender, :last_name, :name, :offer_uuid,
    :password_digest, :password_reset_generated_at, :password_reset_token, :stripe_customer_id,
    :subscription_plan_uuid, :mobile_phone, :time_zone, :receive_sms_notifications, :facebook_auth_token,
    :stripe_subscription_status, :stripe_subscription_status_updated

  has_many :enrollments, primary_key: 'uuid', foreign_key: 'user_uuid', dependent: :destroy
  has_many :assessments, through: :enrollments

  attr_reader :password
  attr_accessor :password_confirmation

  GENDERS = ['male', 'female']
  RELATIONSHIP_STATUSES = ['single', 'in a relationship', 'married']
  HOME_ENVIRONMENTS = ['urban', 'suburban', 'rural']
  WORKPLACE_ENVIRONMENTS = ['home', 'office', 'other']
  AGE_DEMOGRAPHICS = ['18-24', '25-35', '36-45', '46-55', '56+']

  validate :password_validations
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :first_name, presence: true
  validates :gender, inclusion: {in: GENDERS, allow_nil: true}
  validates :relationship_status, inclusion: {in: RELATIONSHIP_STATUSES, allow_nil: true}
  validates :home_environment, inclusion: {in: HOME_ENVIRONMENTS, allow_nil: true}
  validates :workplace_environment, inclusion: {in: WORKPLACE_ENVIRONMENTS, allow_nil: true}
  validates :age_demographic, inclusion: {in: AGE_DEMOGRAPHICS, allow_nil: true}
  validates :mobile_phone, presence: {if: :receive_sms_notifications?}, format: {with: /\A[2-9]([02-9][0-9]|[0-9][02-9])[02-9][0-9]{6}\Z/, allow_blank: true}
  validates :time_zone, presence: {if: :receive_sms_notifications?}

  after_save :create_stripe_account
  after_save :clear_password_reset_token

  ################################################################################
  # instance methods
  ################################################################################

  def current_enrollment
    enrollments.last
  end

  def current_action_plan
    current_enrollment.try(:current_action_plan)
  end

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name=(value)
    names = value ? value.split(' ') : ['','']
    self.last_name = names.pop unless names.length < 2
    self.first_name = names.join(' ')
  end

  def terms_accepted?
    self.terms_accepted_on.present?
  end

  def onboarding_completed?
    name.present? && gender.present? && relationship_status.present? && age_demographic.present?
    # name.present? && gender.present? && relationship_status.present? && home_environment.present? &&
      # workplace_environment.present? && age_demographic.present? && !children.nil? && terms_accepted?
  end

  def male?
    gender.present? && gender.to_sym == :male
  end
  def female?
    gender.present? && gender.to_sym == :female
  end

  def married?
    relationship_status.present? && relationship_status.to_sym == :married
  end
  def single?
    relationship_status.present? && relationship_status.to_sym == :single
  end
  def relationship?  # NOTE that married and relationship are orthogonal here.
    relationship_status.present? && relationship_status.to_s == 'in a relationship'
  end
  alias :in_a_relationship? :relationship?

  def parent?
    children
  end

  def date_of_birth=(value)
    write_attribute(:date_of_birth, value)
    self.age_demographic = User.age_demographic_for(value) if value
  end

  def self.age_demographic_for(date_of_birth)
    return nil unless date_of_birth

    # convert to a Date object
    date_of_birth = Date.parse(date_of_birth.to_s) unless date_of_birth.is_a?(Date)

    years_ago = Time.now.year - date_of_birth.year
    # AGE_DEMOGRAPHICS = ['18-24', '25-35', '36-45', '46-55', '56+']
    case years_ago
    when 0..24;  AGE_DEMOGRAPHICS[0]
    when 25..35; AGE_DEMOGRAPHICS[1]
    when 36..45; AGE_DEMOGRAPHICS[2]
    when 46..55; AGE_DEMOGRAPHICS[3]
    else; AGE_DEMOGRAPHICS[4]
    end
  end

  def mobile_phone=(value)
    # normalize to store only digits
    write_attribute(:mobile_phone, value.try(:gsub, /[^0-9]/, ""))
  end

  ############################################################
  # offers & subscription plans
  ############################################################

  def offer
    @offer ||= Offer.where(uuid: self.offer_uuid).first
  end

  def subscription_plan
    @subscription_plan ||= SubscriptionPlan.where(uuid: self.subscription_plan_uuid).first
  end

  def set_offer_and_subscription_plan!(offer, plan)
    if offer && offer.available?
      write_attribute(:offer_uuid, offer.uuid)
      Rails.logger.info "offer_uuid set to #{offer.uuid} for user #{self.uuid}"
    end

    if plan && plan.active? && stripe_customer
      # for now, we're handling non-recurring subscriptions by applying & canceling it immediately
      # this should be handled differently in the future, as it prevents the usage of trial periods
      # which sets the subscription status to 'trialing' until the end of the trial period

      # todo: handle trial period
      # trial = plan.trial_period.days.from_now.to_i unless plan.trial_period.nil?
      # @customer.update_subscription(plan: plan.stripe_plan_id, trial_end: trial)

      stripe_customer.update_subscription(plan: plan.stripe_plan_id)
      stripe_customer.cancel_subscription(at_period_end: true) unless plan.recurring?

      # ends_at = Time.at(stripe_customer.subscription.current_period_end)
      update_attributes(subscription_plan_uuid:plan.uuid)
      Rails.logger.info "subscription_plan_uuid set to #{plan.uuid} for user #{self.uuid}"
    end

    # save the damn user!
    self.save
  end

  # remote operation
  def apply_stripe_coupon!(coupon_code)
    stripe_customer.coupon = coupon_code if coupon_code
    @_customer = stripe_customer.save
    Rails.logger.debug "Stripe coupon applied."
  end

  # remote operation
  def update_stripe_card!(card_token)
    stripe_customer.card = card_token if card_token
    @_customer = stripe_customer.save
    Rails.logger.debug "Stripe card updated."
  end

  # remote operation
  def current_stripe_subscription(reload=false)
    @_current_stripe_subscription = nil if reload
    @_current_stripe_subscription ||= stripe_customer.subscription
  end

  # remote operation
  def update_stripe_subscription_status!
    log "update_stripe_subscription_status (before): #{current_stripe_subscription.try(:status)}"
    self.stripe_subscription_status = current_stripe_subscription.try(:status)
    log "update_stripe_subscription_status (after): #{self.stripe_subscription_status}"
    self.stripe_subscription_status_updated = Time.now
    self.save!
  end

  # remote operation
  def cancel_subscription!
    stripe_customer.cancel_subscription(at_period_end: true)
    update_stripe_subscription_status!
  end

  def stripe_subscription_active?
    # get current status from Stripe if it's not valid or older than 5 minutes
    update_stripe_subscription_status! if VALID_STRIPE_SUBSCRIPTION_STATUSES.exclude?(self.stripe_subscription_status) ||
      self.stripe_subscription_status_updated < 5.minutes.ago

    VALID_STRIPE_SUBSCRIPTION_STATUSES.include?(self.stripe_subscription_status)
  end

  def subscription_canceled?
    stripe_subscription = current_stripe_subscription

    CANCELED_STRIPE_SUBSCRIPTION_STATUSES.include?(self.stripe_subscription_status) || stripe_subscription.canceled_at
  end

  ################################################################################
  # passwords
  ################################################################################
  #
  # has_secure_password still sucks in Rails 3.2 because you can't disable
  # validations, so we'll handle password encryption ourselves. This will also
  # allow us to support multiple encryption systems.

  def password_validations
    # skip password validation if the password is blank and there's a Facebook ID or
    # the record has already been saved
    return if self.password.blank? && (self.facebook_identifier.present? || self.persisted?)

    # validate using the awesome Bloomdido PasswordValidator gem
    validates_with PasswordValidator, min_length: 6, common: true, confirmation: true
  end

  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest) == unencrypted_password && self
  end

  def password=(unencrypted_password)
    @password = unencrypted_password
    self.password_digest = BCrypt::Password.create(unencrypted_password) unless @password.blank?
  end

  def clear_password_reset_token
    if password_digest_changed?
      self.update_column(:password_reset_token, nil)
      self.update_column(:password_reset_generated_at, nil)
    end
  end

  def generate_password_reset_token!
    self.update_attributes(password_reset_token:SecureRandom.urlsafe_base64(12), password_reset_generated_at:Time.now)
  end

  ################################################################################
  # stripe
  ################################################################################

  def create_stripe_account
    return if self.stripe_customer_id

    begin
      customer = Stripe::Customer.create(email: self.email)
      self.stripe_customer_id = customer.id if customer
      self.save
    rescue Stripe::StripeError => e
      Rails.logger.error "Error creating Stripe account for user #{self.uuid}: #{e.message}"
    end
  end

private

  def stripe_customer
    create_stripe_account unless self.stripe_customer_id
    @_customer ||= Stripe::Customer.retrieve(self.stripe_customer_id)

  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Couldn't retrieve Stripe account for user #{self.uuid}: #{e.message}"

    # create new account and try again
    self.stripe_customer_id = nil
    create_stripe_account
    @_customer ||= Stripe::Customer.retrieve(self.stripe_customer_id)
  end

end
