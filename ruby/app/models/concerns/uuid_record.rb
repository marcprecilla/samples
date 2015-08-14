module UUIDRecord
  extend ActiveSupport::Concern
  
  UUID_REGEX = /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
  
  def self.is_uuid?(str)
    return false if str.nil?
    (str.downcase =~ UUID_REGEX) == 0
  end
  
  included do
    attr_readonly :uuid
    validates :uuid, :presence => true
    
    # We shouldn't try to validate uuid uniqueness through ActiveRecord because:
    #
    # 1. The probability of coincidental UUID conflicts is astronomically low
    # 2. ActiveRecord uniqueness validations are subject to failure due to race conditions
    # 3. Uniqueness can (and should) be guaranteed by use of a db index
    # 4. It adds an extra SQL query to every db CREATE call

    after_initialize :generate_uuid
    before_create :generate_uuid
  end
  
  module ClassMethods
    def find_by_uuid(uuid)
      self.where(:uuid => uuid.to_s).first
    end
  end
  
  def uuid=(value)
    write_attribute(:uuid, value.to_s)
  end

  def to_param
    self.uuid
  end
  
  def as_json(options=nil)
    options ||= { :except => [] }      
    options[:except] = Array.wrap(options[:except]) << :id
    super(options)
  end

private
  def generate_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end
end
