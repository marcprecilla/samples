class Invitation < ActiveRecord::Base
  include UUIDRecord

  attr_accessible :uuid, :sent_at, :received_at,
    :recipient, :recipient_name, :recipient_type, # recipient is email address, mobile phone, or facebook id
    :sender_uuid, # user who generated the invitation
    :subject, :subject_type # uuid of assessment or friendship request

  belongs_to :sender, class_name: 'User', primary_key: 'uuid', foreign_key: 'sender_uuid'

  RECIPIENT_TYPES = %w(email mobile_number facebook_id anonymous)
  SUBJECT_TYPES = %w(three_sixty_assessment friendship_request)

  validates :sender_uuid, presence: true
  validates :recipient_name, presence: true
  validates :recipient, presence: true, uniqueness: {scope: [:sender_uuid, :recipient_type, :subject, :subject_type], message: "has already been sent an invite"}, email: true
  validates :recipient_type, inclusion: RECIPIENT_TYPES
  validates :subject, presence: true
  validates :subject_type, inclusion: SUBJECT_TYPES

  def sent?
    self.sent_at.present?
  end

  def received?
    self.received_at.present?
  end

  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless record.recipient_type != 'email' || value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        record.errors[attribute] << (options[:message] || "is not an email")
      end
    end
  end

end