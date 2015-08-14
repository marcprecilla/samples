class Category < ActiveRecord::Base
  include UUIDRecord
  
  attr_accessible :description, :name, :uuid

  has_many :checks, primary_key: 'uuid', foreign_key: 'category_uuid'
  has_many :interventions, primary_key: 'uuid', foreign_key: 'category_uuid'

  def responses_for_days(range, enrollment)
  	 checks.collect do |check|
  		check.responses_for_days(range, enrollment)
  	end.flatten
  end
end
