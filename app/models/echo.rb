#Other users can echo a shoutout into a ring of their choice, where they share the original author's shoutout with their own friends.
#Echoes can be further echoed through vibrations.
#An echo keeps track of it's distance from the original shoutout

#On creation, an echo needs 
# a shoutout_id
#and can also take
# a vibration_attributes hash
#It must be built off ring_id: 
# ring.echoes.build()

class Echo < ActiveRecord::Base
  attr_accessible :shoutout_id, :signalled, :vibration_attributes #to set the ring_id, build off of the user's ring.
  
  belongs_to :ring
  has_one :user, :through => :ring
  belongs_to :shoutout
  
  has_one :vibration, :foreign_key => :child_id, :dependent => :destroy
  has_one :parent, :through => :vibration
  has_many :vibrations, :foreign_key => :parent_id
  has_many :children, :through => :vibrations

  #Must follow associations
  accepts_nested_attributes_for :vibration, :reject_if =>  proc{|attributes| Vibration.new(attributes).invalid?}

  validates :shoutout_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}, :uniqueness => {:scope => :ring_id}
  validates :ring_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  # validates :vibration_id, :numericality => {:only_integer => true, :greater_than => 0, :if => proc{|echo| !echo.vibration_id.blank?} }
  # validates :signalled, :presence => true # raises an error even with before_validation :fill_in_blanks
  validates :distance, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  validate :within_echo_range
  validate :friendship_necessary
  # validate :no_repeats_by_same_user
  
  before_validation :fill_in_blanks
  
  private
  
  def fill_in_blanks
    set_distance
    set_signalled
    return true
  end
  
  def set_distance
    if self.vibration.nil?
      self.distance = 1
    else
      self.distance = self.parent.distance + 1
    end
  end
  
  def set_signalled
    unless self.signalled == true
      self.signalled = false
    end
  end
  
  def within_echo_range
    #Should be working
    unless self.shoutout.nil?
      if self.distance > self.shoutout.echo_range and self.shoutout.echo_range != -1
        self.errors.add(:distance, 'too far from original shoutout')
      end
    end
  end
  
  def no_repeats_by_same_user
    #I think this works
    unless self.shoutout.nil? or self.ring.nil?
      if self.user.nil?
        self.errors.add(:ring_id, 'is not associated to a user')
      elsif self.user.echoes.exists?(:primary_key => !nil, :shoutout_id => self.shoutout_id)
        self.errors.add(:shoutout_id, 'has already been echoed by you')
      end
    end
  end
  
  def friendship_necessary
    #Hasn't been successfully tested
    
    #If the echo distance is 1, a mutual friendship with the original shoutout is required.
    # Otherwise, a mutual friendship with the parent echo is required.
    unless self.shoutout.nil? or self.ring.nil? or self.user.nil?
      if self.vibration.nil?
        if self.user.mutual_friends.include?(self.shoutout.author)
          unless self.shoutout.author.mutual_friendships.find_by_friend_id(self.user.id).ring.number <= self.shoutout.ring.number
            self.errors.add(:shoutout_id, 'is written by a friend that is too far away')
          end          
        else
          self.errors.add(:shoutout_id, 'is not written by a friend')
        end
      else
        if self.user.mutual_friends.include?(self.parent.user)
          unless self.parent.user.mutual_friendships.find_by_friend_id(self.user.id).ring.number <= self.shoutout.ring.number
            self.errors.add(:shoutout_id, 'is written by a friend that is too far away')
          end          
        else
          self.errors.add(:shoutout_id, 'is not written by a friend')
        end
      end
    end
  end
end