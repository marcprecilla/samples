class Part < ActiveRecord::Base
  include UUIDRecord

  attr_accessible :description, :name, :program_order, :program_uuid, :uuid

  belongs_to :program, primary_key: 'uuid', foreign_key: 'program_uuid'
  has_many :steps, primary_key: 'uuid', foreign_key: 'part_uuid'

  validates :program_uuid, presence: true

  # todo: guarantee program_order is correct
end
