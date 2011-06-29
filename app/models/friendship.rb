#Friendships associate Users to Users.

#Note self.ring.user_id could be replaced by self.user.id  ....saves a query

class Friendship < ActiveRecord::Base
  #Must be able to change the ring_id...but not the friend_id.
  attr_accessible :ring_id, :message, :note, :mutual, :cone_connections_attributes#, :friend_id
  
  #Associations
  belongs_to :ring
  belongs_to :friend, :class_name => 'User'
  has_one :activity, :as => :entity, :dependent => :destroy
  has_one :user, :through => :ring
  has_one :profile, :through => :ring
#  has_many :friend_friendships, :through => :friend, :source => :friendships                 #Requires nested has_many :through sql command
#  has_many :friend_mutual_friendships, :through => :friend, :source => :mutual_friendships   #Requires nested has_many :through sql command
  has_many :cone_connections
  has_many :cones, :through => :cone_connections
  
  #Must follow associations
  accepts_nested_attributes_for :cone_connections, :reject_if =>  proc{|attributes| !ConeConnection.new(attributes).valid?}, :allow_destroy => :true

  #Validations

  validates_presence_of :friend_id, :ring_id
  validates_numericality_of :friend_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :ring_id, :only_integer => true, :greater_than => 0
  validate :extraverted
  validate :unique_friendship, :on => :create

  #in conjunction with unique friendship, user should definitely NOT be able to have two friendships with the same user
  # validates_uniqueness_of :friend_id, :scope => :ring_id 
  # validates_associated :ring, :friend

  #Callbacks
  #before_save :check_validity_of_cone_connections #can't get this to work
  # before_update :static_associations
  after_create :make_mutual  #Maybe should be :before_create or :after_validations_on_create
  before_destroy :delete_inverse
  
  public
  
  #Returns true if there exists a friendship between the user and the friend in the opposite direction as this.
  def mutual_exists?
    if self.friend.friendships.exists?(:friend_id => self.ring.user_id) or self.friend.mutual_friendships.exists?(:friend_id => self.ring.user_id)
      return true
    else
      return false
    end
  end

  #Returns the friendship going from self.friend to self.ring.user
  def mutual_friendship
    if self.friend.friendships.exists?(:friend_id => self.ring.user_id)  #Different from mutual_exists!
      return self.friend.friendships.find_by_friend_id(self.ring.user_id)
    else
      return self.friend.mutual_friendships.find_by_friend_id(self.ring.user_id)
    end
  end
  
  private  
  
  #After creation, this method is called to set the mutual value of both this friendship and the inverse_friendship to true
  def make_mutual
    if self.mutual_exists? == true
      #COULD write this in addtion to the previous line with AND...but would it execute if self.mutual_exists? == false ?
      if self.mutual_friendship.update_attributes(:mutual => true)
        self.mutual = true 
        self.save
      else
        self.mutual = false
        self.save
      end
    else
      self.mutual = false
    end
  end  
  
  #Before deletion, this method is called to ensure that the inverse relationship
  #is destroyed if it exists.
  def delete_inverse
    self.mutual? ? self.mutual_friendship.delete : nil
    self.delete
  end

  #Validates against friendships with one's self.
  def extraverted
    if self.ring.nil? == false   #The ring should NOT be nil, but this prevented by validates_presence of :ring
      if self.ring.user_id == friend_id
        errors.add(:friend_id, 'cannot be yourself!') 
      end 
    else
      errors.add(:ring_id, 'doesn\'t exist! (Extraverted)')
    end
  end 
  
  #Validates against having multiple friendships with the same user.
  def unique_friendship
    if self.ring.nil? == false   #The ring should NOT be nil, but this prevented by validates_presence of :ring
      if self.ring.user.friendships.exists?(:friend_id => self.friend_id) or self.ring.user.mutual_friendships.exists?(:friend_id => self.friend_id)
        errors.add(:friend_id, 'has already received your friendship.')
      end
    else
      errors.add(:ring_id, 'doesn\'t exist! (Unique)')
    end
  end
  
  #Prevents the associations from being altered upon update
  def static_associations
    identity = Friendship.find_by_ring_id_and_by_friend_id(:ring_id => self.ring_id, :friend_id => self.friend_id)
  end
  
  def check_validity_of_cone_connections
    saveable = true
    self.cone_connections.each do |connection| 
      connection.check_validity
      connection.errors.empty? ? nil : saveable = false
    end
    (saveable == true) ? self.save! : (return false)
  end
end