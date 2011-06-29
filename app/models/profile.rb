# A user has many profiles to present a gradient of personal information to his/her many rings.
#But he should feel like there is only ONE profile, where each tidbit of information is assigned a minimum proximity.
#I informally considered making a single profile for a user and then assigning ring values to each attribute...
#...I think that this is easier, if not less intuitive and conducive to schizophrenia.

#To do:  
#Validate sex as male or female
#Create association to locations
#Write work and study history
#Add locations visited
class Profile < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :sex, :birthdate
  
  belongs_to :ring
  has_one :user, :through => :ring
  has_many :activities, :as => :entity, :dependent => :destroy
  
  #Validations
  validates_presence_of :ring_id
  validates_numericality_of :ring_id, :only_integer => true, :greater_than => 0
  validates_uniqueness_of :ring_id
  validates_format_of :first_name, :with => /^[a-z]*$/i, :message => 'must contain only letters.'
  validates_format_of :last_name, :with => /^[a-z]*$/i, :message => 'must contain only letters.'
  
  # before_validation :capitalize_names #I don't think this is really necessary
  # after_create :register_creation #observer
  # after_update :register_update #observer
  after_save :update_projected_name #Could be an observer
  
  def capitalize_names
    unless first_name.nil?
      self.first_name.downcase!
      self.first_name.capitalize!
    end
    unless last_name.nil?
      self.last_name.downcase!
      self.last_name.capitalize!
    end
  end
    
  def register_creation
    self.activities.create(:ring_id => ring_id, :action => 'created_profile')
  end    
  def register_update
    self.activities.create(:ring_id => ring_id, :action => 'updated_profile')
  end    
  
  def update_projected_name #Could be an observer
    if self.first_name.blank? and self.last_name.blank?
      self.ring.update_attribute(:projected_name, self.ring.user.username) #Would really like this to be just self.user.username but I can't get it to work when a new user is created.
    elsif self.first_name.blank?
      self.ring.update_attribute(:projected_name, self.last_name)
    elsif self.last_name.blank?
      self.ring.update_attribute(:projected_name, self.first_name)
    else
      self.ring.update_attribute(:projected_name, self.first_name + ' ' + self.last_name)
    end
  end
  #   if self.first_name.blank? and self.last_name.blank?
  #     self.projected_name =  self.ring.user.username #Would really like this to be just self.user.username but I can't get it to work when a new user is created.
  #   elsif self.first_name.blank?
  #     self.projected_name =  self.last_name
  #   elsif self.last_name.blank?
  #     self.projected_name = self.first_name
  #   else
  #     self.projected_name = self.first_name + ' ' + self.last_name
  #   end
  # end
end