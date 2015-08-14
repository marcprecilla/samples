class Intervention < ActiveRecord::Base
  include UUIDRecord
  
  COMPONENT_TYPE = "intervention"

  attr_accessible :category_uuid, :description, :intervention_type, :key, :name, :uuid, :instructions, :transitions, :audio_url, :audio_duration, :setting, :duration

  belongs_to :category, primary_key: 'uuid', foreign_key: 'category_uuid'
  
  # note that it's not really a good idea to have this association. (it ties the intervention to the Program/Part/Step design)
  has_many :steps, primary_key: 'uuid', foreign_key: 'component_uuid'
  has_many :activities, primary_key: 'uuid', foreign_key: 'intervention_uuid'


  serialize :transitions, Array

  def self.image_url(key)
      "https://s3.amazonaws.com/s3.stresslessapp.myapp.com/interventions/#{key}.jpg"
  end
  def image_url
      self.class.image_url(key)
  end

  # def self.for_day(day, program)
  # 	uuids = program.part_for_day(day).steps.where(component_type:'intervention').collect(&:component_uuid)
  # 	"Error in the db setup for days/steps/interventions for day #{day}.  Number of interventions found is #{uuids.count}, but should be 1" unless uuids.count == 1
  # 	interventions = Intervention.where("uuid in (?)", uuids)
  # 	interventions.first # only one intervention per day for SL
  # end

  # def days_including_this_intervention
  #   steps.collect {|step| step.part.program_order+1}
  # end

  # def part
  #   steps.first.part
  # end
  # def program
  #   part.program
  # end

end
