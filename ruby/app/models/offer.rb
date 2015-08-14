class Offer < ActiveRecord::Base
  include UUIDRecord

  attr_accessible :name, :available, :token, :best_value_plan_uuid, :uuid, :default

  validates :name, presence: true, uniqueness: true
  validates :token, presence: true, uniqueness: true

  has_many :subscription_plans, primary_key: 'uuid', foreign_key: 'offer_uuid', :order => 'updated_at DESC', dependent: :destroy
  has_one :best_value_plan, class_name: 'SubscriptionPlan', primary_key: 'best_value_plan_uuid', foreign_key: 'uuid'

  after_initialize :set_defaults, :create_token

  scope :available, where(available: true)

  def self.set_default(offer)
    self.where(default: true).update_all(default: false)
    offer.update_attributes(default: true, available: true)
  end

  def self.default
    self.available.where(default: true).first || self.available.first
  end

  def set_defaults
    self.available = true if self.available.nil?
  end

  def create_token
    self.token ||= SecureRandom.urlsafe_base64(8)
  end
end
