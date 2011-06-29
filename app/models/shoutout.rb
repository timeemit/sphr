#A shouotut is public correspondence between a user and his friends.
#The content of a the shoutout can be veiwed by the user's mutual friends that are closer than the ring distance of the shoutout set by the author.
#Other users can echo a shoutout into a ring of their choice, where they share the original author's shoutout with their own friends.
#Echoes can be further echoed through vibrations.
#A shoutout keeps count of the total number of echoes that it has spawned.
#The user can signal other mutual friends to be signalled by the shoutout to make sure that they see the shoutout.
#A user can specify the maximum distance that an echo can have, where -1 is infinite.
#However, anyone signalled in a shoutout can turn the signal into an echo, regardless of the echo range of the shoutout.

#todo Maybe create a shoutback, which would essentially be comments?
# todo Shoutout to shoutout join model?

class Shoutout < ActiveRecord::Base
  attr_accessible :content, :echo_range, :ring_id #:user_id would never be changed, but :ring_id is flexible
  
  #Associations
  belongs_to :ring
  belongs_to :author, :class_name => 'User'
  has_one :user, :through => :ring
  has_many :light_signals
  has_many :echoes
    
  has_many :cone_permissions, :as => :entity
  has_many :permitted_cones, :through => :cone_permissions, :source => :cone
  has_many :comments
  has_one :activity, :as => :entity, :dependent => :destroy
  has_many :reactions

  #Validations
  
  validates :ring_id, :presence => true, :numericality => {:only_intger => true, :greater_than => 0}
  validates :author_id, :presence => true, :numericality => {:only_intger => true, :greater_than => 0}
  validates :echo_range, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => -1}
  validates :echo_count, :presence => true, :numericality => {:only_intger => true, :greater_than_or_equal_to => 0}
  validates :content, :presence => true, :uniqueness => {:scope => :ring_id}
  
  #Callbacks
  before_validation :initialize_echo_count
  # after_create :register_action  
  
  private
  
  def initialize_echo_count
    self.echo_count = 0
  end
  
  def register_action
    if recipient_type == 'User'
      self.create_activity(:user_id => user.id, :action => 'created_post_for_user')
    end
  end
end

#Shoutout are similar to wall posts on Facebook.
#If there is no recipient, the author can choose what maximum ring distance a mutual friend can have to view the shoutout.
#If a recipient is specified, the maximum ring distance of the shoutout is the one that the recipient has put the author in.
# Then the recipient can specify the ring of the shoutout at will.
#I don't know how to deal with tags:
# Should they be availble when a recipient is defined?
# Whose rings can see if someone is tagged?  The tagged user?
#March 14th tag ideas:
# Author can tag his/her mutual friends in any shoutout regardless of the presence of the recipient.
# Initially, the only ring that sees the shoutout is the one that the recipient designates.
# After a period of time (a time that the recipient can specify as a default preference...initially a day), 
# the shoutout will echo into the ring of the tagged the recipient (or maybe the author?) is in.
#March 14th signal ideas:
# Author can SIGNAL his/her mutual_friends in any shoutout regardless of the recipient.
# A signalled user can then REVEAL the shoutout to a ring of his/her choosing (after being prompted the ring of either the author or the recipient)
# A recipient can BLOCK the signals of a shoutout that he/she receives.
#Additional thought:
# Perhaps a signal will be revealed after a certain amount of default time.
# When a user sends a shoutout to a recipient, a signal is immediately reflected back to him.
#March 15th ideas:
# The author ALWAYS specifies the farthest ring of friends that can see the shoutout.
# If there is a recipient, the recipient can select an ADDITIONAL farthest ring of friends that can see the shoutout
# 
#Recipients were originally written as polymorphic because groups of users, called clusters, might also be able to receive shoutouts in the future.
# This seemed to limit the flexibility of the shoutout model.

# has_many :rings_shoutouts
# has_many :recipient_rings, :through => :rings_shoutouts
# # Moreover, ring_shoutout should have a Type attribute that can be either 'Original' or 'Signalled' 
# # to distinguish between the original recipient and the friends that revealed the shoutout that they had been signalled in.
# # belongs_to :recipient #Replace with above three lines
# # belongs_to :ring #Is this the ring of the user, the recipient, or is it even necessary?
# Shoutout_users are created upon the observation of when permitted_cones are saved or when new rings are designated to the shoutout
# has_many :shoutout_users 
# has_many :users, :through => :shoutout_users #The users are the people that can view the shoutout
