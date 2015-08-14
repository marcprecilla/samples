class Check < ActiveRecord::Base
  include UUIDRecord

  COMPONENT_TYPE = "check"

  scope :three_sixty, where(check_type: 'three_sixty')
  scope :baseline, where(check_type: 'baseline')
  scope :checkin, where(check_type: 'check-in')
  scope :big5, where(check_type: 'big5')

  attr_accessible :category_uuid, :category, :check_type, :inverse_scoring, :max_response_value, :min_response_value, :response_descriptions, :text, :uuid, :version

  serialize :response_descriptions, Hash

  # belongs_to :category, primary_key: 'uuid', foreign_key: 'category_uuid'
  has_many :responses, primary_key: 'uuid', foreign_key: 'check_uuid'
end
