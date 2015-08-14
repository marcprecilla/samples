class Lead < ActiveRecord::Base  
	attr_accessible :name, :email, :original_url, :source, :campaign, :date_of_birth,
	    :gender, :relationship_status, :assessment_uuid, :landing_page
	validates :email, presence: true

  belongs_to :assessment, primary_key: 'uuid', foreign_key: 'assessment_uuid'

	def age_demographic
		User.age_demographic_for(Date.parse(date_of_birth))
	rescue
		nil
	end

	def self.csv_header_array
		['Email', 'Name', 'Created', 'Source', 'Campaign', 'Landing Page', 'Gender', 'DOB', 'Age', 'Relationship', 'Assessment', 'Original Url']  
  end
  def csv_row_array
    [email, name, created_at.strftime("%d %b %y"), source, campaign, landing_page, gender, date_of_birth, user_age_demographic, relationship_status, assessment_uuid, original_url]  
  end

  def first_name
    self.name ? self.name.partition(' ').first : ''
  end

  def last_name
    self.name ? self.name.partition(' ').last : ''
  end

end
