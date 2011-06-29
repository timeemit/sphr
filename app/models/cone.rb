class Cone < ActiveRecord::Base
  #MUST successfully write attr_accessible for cone_connection association
  attr_accessible :name, :cone_connections_attributes
  
  belongs_to :user
  has_many :cone_connections, :dependent => :destroy
  has_many :friendships, :through => :cone_connections

  #Must follow associations
  accepts_nested_attributes_for :cone_connections, :reject_if =>  proc{|attributes| !ConeConnection.new(attributes).valid?}

  validates_presence_of :name, :user_id
  validates_numericality_of :user_id, :only_integer => true, :greater_than => 0
  validates_format_of :name, :with => /^[a-z0-9\s]+$/i, :message => "must consist of only letters and numbers."
  # validate :cone_connections_values
  
  #before_save :check_validity_of_cone_connections Can't get this to work
  
  private
  
  # #This is the logic behind the reject_if option of the accepts_nested_attributes
  # def blank_cone_connection_attributes(attributes)
  #   if ConeConnection.new(attributes).valid?
  #     return false
  #   else
  #     return true
  #   end
  # end
  
  # def cone_connections_values
  #   ccs = self.cone_connections.all(:id => nil)
  # end
  
  # def check_validity_of_cone_connections
  #   saveable = true
  #   self.cone_connections.each do |connection| 
  #     connection.check_validity
  #     connection.errors.empty? ? nil : saveable = false
  #   end
  #   saveable.true? ? self.save! : (return false)
  # end
end