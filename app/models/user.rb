#The user is the centerpiece of the FrndSphr social network.
#See the APPLICATION_DESCRIPTION in the doc file to read more about the website in general.

#The user model contains a username, password, email, and a distinction that helps other people identify who they are.
#The user is related to other users via friendships, which he/she can organize into rings and cones.
class User < ActiveRecord::Base
  attr_accessible :username, :password, :password_confirmation, :email, :email_confirmation, :distinction
  
  #Associations
  
  #The ring is the most unique aspect of this social network.
  #A user can assign friendships and profiles to rings so as to control what information each ring has.
  #Accessed rings are the rings that the user has been placed in by his/her mutual_friends.
  has_many :rings, :dependent => :destroy
  has_one :public_ring, :class_name => 'Ring', :conditions => {:name => 'Public'}
  has_many :accessed_rings, :through => :inverse_mutual_friendships, :source => :ring
  
  #The following four lines of code have been adapted from http://railscasts.com/episodes/163-self-referential-association
  #The friendship is at the core of the social network, and represents a connection between two users.
  
  #Friendships are just proposals and have not yet been extended.
  has_many :friendships, :through => :rings, :source => :friendships, :conditions => {:mutual => false}, :dependent => :destroy #Mutual is false to distinguish it from mutual_friendships, which are seen later.
  #The friendship is only the connection between two users.  A friend is the other user that self is connected to.
  has_many :friends, :class_name => 'User', #this SQL command seems to return a simple Array and not an active record object
    :finder_sql => 'SELECT u.* FROM users u ' +
    	                'INNER JOIN friendships f ON (f.friend_id = u.id) ' +
        		            'INNER JOIN rings r ON (r.id = f.ring_id) ' +
        		        'WHERE (r.user_id = #{self.id} AND f.mutual = 0)'
  
  #Of course, the friendship is only one way, and represents more of a friendship proposal than an actual friendship.
  has_many :inverse_friendships, :class_name => 'Friendship', :foreign_key => 'friend_id', :conditions => {:mutual => false}, :dependent => :destroy
  #Inverse friends are, therefore, users that have proposed a friendship to you.
  has_many :inverse_friends, :class_name => 'User', 
    :finder_sql => 'SELECT u.* FROM users u
                    	INNER JOIN rings r ON r.user_id = u.id
                    		INNER JOIN friendships f ON f.ring_id = r.id
                    WHERE (f.friend_id = #{self.id} AND f.mutual = 0)'

  #Once an invitation is accepted, the friendship is marked as mutual, hence the mutual_friendship...
  has_many :mutual_friendships, :through => :rings, :source => :mutual_friendships, :conditions => {:mutual => true}, :readonly => false, :dependent => :destroy
  #...and corresponding friends
  has_many :mutual_friends, :class_name => 'User',
    :finder_sql => 'SELECT u.* FROM users u
  	                  INNER JOIN friendships f ON (f.friend_id = u.id)
      		              INNER JOIN rings r ON (r.id = f.ring_id)
      		          WHERE (r.user_id = #{self.id} AND f.mutual = 1)'

  #Inverse mutual friendships is useful for getting the profile information of inverse friends
  has_many :inverse_mutual_friendships, :class_name => 'Friendship', :foreign_key => 'friend_id', :conditions => {:mutual => true}, :dependent => :destroy
    
  #Not only can Users manage their friends into friendships, they also have cones of friends.
  #These are just groups of friends.  It gives the user greater control over his/her friends
  has_many :cones, :dependent => :destroy

  #Shoutouts are public announcements between users that can be seen by mutual friends
  has_many :shoutouts, :through => :rings, :dependent => :destroy
  has_many :authored_shoutouts, :class_name => 'Shoutout', :foreign_key => 'author_id', :dependent => :destroy

  #Echoes repeat the message sent by a shoutout but but to a new user's friends.
  has_many :echoes, :through => :rings, :dependent => :destroy
    
  #Users can write comments on posts.
  has_many :comments, :dependent => :destroy
  
  #Actions such as creating posts, comments, or friendships are recorded as activities,
  #which can be seen by the user's friends to encourage communication.
  has_many :activities, :through => :rings, :dependent => :destroy

  #A user has multiple profiles to manage his(/her) appearance to each ring of friends
  has_many :profiles, :through => :rings, :dependent => :destroy
  has_one :public_profile, :through => :public_ring, :source => :profile
  #Could run a :finder_sql query that retrieves the viewable profiles of all of the user's mutual friends...would it be useful?
  
  #Currently, a User's Preference only describes the number of rings the user wishes to have.
  #More will be added, I'm sure.  If not other preferences (cones_preference, commerce_preference, etc...)
  has_one :preference, :dependent => :destroy   
  
    
  #Validations
	
	validate :non_email_fields_blank_upon_creation, :on => :create
	
	validates :username,
	            :presence => true,
	            :uniqueness => true,
	            :length => {:within => 4..20},
	            :format => {
	              :with => /^[a-z0-9]+$/i,
            		:message => "must consist of only alphanumeric characters."
            	},
            	:on => :update
	            
  validates :password,
              :presence => true,
              :confirmation => true,
              :length => {:within => 5..30},
              :format => {
                :with => /^\w*(?=\w*\d)(?=\w*[a-z])(?=\w*[A-Z])\w*$/,
            		:message => "must have at leaset one lowercase letter, one uppercase letter, and one number."
              },
              :on => :update
  
  validates :password_confirmation, #Probably unnecessary, since :confirmation => true is written
              :presence => true,
              :on => :update
  
  validates :email,
              :presence => true,
	            :uniqueness => true,
	            :confirmation => true,
	            :format => {
	              :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i,
            		:message => "addresses begin with alphanumeric characters, followed by an @ sign, 
                  followed by a period delimited server name."
	            }
  
  validates :email_confirmation, #Probably unnecessary, since :confirmation => true is written
              :presence => true
              
  validates :distinction,
              :presence => true,
              :length => {:maximum => 200},
              :uniqueness => { #Quite unnecessary
                :message => 'in this exact writing has already been taken!  
                  Please try something slightly different.'
              },
              :on => :update
	
  # validates_presence_of :username, :password, :email, :distinction, :message => 'is a required field.'
  # validates_presence_of :email_confirmation, :password_confirmation, :message => 'was not present.'
		
  # validates_uniqueness_of :username, :email, :message => 'has already been taken.'
  #   validates_uniqueness_of :distinction, :message => 'in this exact writing has already been taken!  Please try something different.'
	
  # validates_confirmation_of :email, :password, :message => 'did not match confirmation.'

  # validates_length_of :username, :within => 4..20
  # validates_length_of :password, :within => 5..30
	
  # #Requires Usernames to consist of of only punctuated alphanumeric characters
  # validates_format_of :username, :with => /^[a-z0-9]+$/i,
  #   :message => "must consist of only alphanumeric characters."
  #   
  # #Requires Passwords to consist of at least one number,
  # #one uppercase character, and one lower case character
  # validates_format_of :password, :with => /^\w*(?=\w*\d)(?=\w*[a-z])(?=\w*[A-Z])\w*$/,
  #   :message => "must have at leaset one lowercase letter, one uppercase letter, and one number." 
  #   
  # #Requires Email to begin with include any word character, ".", "%", "_", "+", or "-" before the "@" 
  # #followed by a word character, ".",
  # validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i,
  #   :message => "addresses begin with alphanumeric characters, followed by an @ sign, 
  #       followed by a period delimited server name."
	
  
  #Methods
	
  public
  
  #find_activities creates a chronological list of the this user's friend's activities.
  def find_activities
    #This needs to be updated to handle the Ring Model
    #Unit Test is in activity_test.rb
    activities = Array.new
    for friend in mutual_friends
      for activity in friend.activities
        #Does the user have permission to view the activity?
        #The friend must have the user in a ring of equal distance or closer than the content created.
        #However, Comments don't have a ring number, so their respective posts must be referred to.
        if activity.entity_type == 'Comment'
          #The user must be close enough to his/her friend 
          if activity.entity.post.ring >= friend.which_ring(self)
            activities << activity
          end
        elsif activity.entity.ring >= friend.which_ring(self)
          if activity.entity_type == 'Friendship'
            #A mutual friendship creates two activities--one for each friendship.
            #This makes sure that only one activity is seen in the list.
            activities.include?(activity.entity.mutual_friendship.activity) ? nil : activities << activity
          else 
            activities << activity
          end
        end
      end
    end
    #Sort the activity chronologically
    activities.sort!{|a, b| b.updated_at<=>a.updated_at}
    return activities
  end
  
  # #Boolean function that returns true if other_user is a friend of the this user.
  # def friend_is?(other_user)
  #   #Friendship.find_by_user_id_and_friend_id(id, other_user.id).nil? ? (return false) : (return true)
  #   # Unit Test is in Friendship.rb
  #   friends.exists?(other_user)
  # end
  
  # #Returns the friendship between self and the passed user.
  # def friendship_with(other_user)
  #   # Unit Test is in Friendship.rb
  #   return Friendship.find_by_user_id_and_friend_id(id, other_user.id)
  # end
    
  # #Returns true if the other_user is a mutual friend of the User (self)  
  # def is_mutual_friend?(other_user)
  #   # Unit Test is in Friendship.rb
  #   mutual_friends.exists?(other_user)
  #   
  #   #friendship = Friendship.find_by_user_id_and_friend_id(id, other_user.id)
  #   #if friendship.nil?
  #   #  return false
  #   #else      
  #   #  friendship.mutual ? (return true) : (return false)
  #   #end
  # end

  #Creates a two dimensional array representing friends of friends.
  def friends_of_friends
    # Unit Test is in Friendship.rb
    #The first 'row' is a list of the user's friends of friends,
    #which are each in rings farther than the ring of the friend's friendship with the user
    #The second 'row' is the number of common friends the user has with the person listed in the first row.
    friends_of_friends = Array.new
    for friend in self.mutual_friends
      for friend_of_friend in friend.mutual_friends
        #A friend's friend is only seen if you are as close or closer to your friend as your friend's friend.
        if friend.which_ring(friend_of_friend) >= friend.which_ring(self)
          #If you can view the friend, then his/her presence in the friend_of_friends list is determined
          if friends_of_friends.flatten.include?(friend_of_friend)
            #If he/she is in the list, then just the number of common friends in the second row of the correct friend is incremented.
            friends_of_friends.assoc(friend_of_friend)[1] += 1
          else
            #If he/she isn't in the list, then a new column is added to the list unless the friend is you or he/she is already your friend.
            unless friend_of_friend == self or self.friends.exists?(friend_of_friend.id)
              friends_of_friends << Array.[](friend_of_friend, 1) 
            end
          end
        end
      end
    end
    return friends_of_friends
  end

  #name returns either the user's username, first name, last name, or both first name and last name depending on the ring user puts other_user.
  # def name(other_user)
  #   # This function has been MOVED to the Profile model
  #   # Unit Test is in Profile.rb
  #   name = ''
  #   #If a mutual friend is viewing me or I am viewing myself...
  #   if is_mutual_friend?(other_user) or other_user == self
  #     #Check if the first_name of the proper profile is nil or blank
  #     unless which_profile(other_user).first_name.nil? or which_profile(other_user).first_name.empty?
  #       #It isn't, so start name off with first_name
  #       name << which_profile(other_user).first_name
  #     end
  #     #By now there should be a first name in name.
  #     if (name.empty? or name.nil?) and which_profile(other_user).last_name.nil?
  #       #But there isn't and to top it all off, my last name is nil.
  #       #so my name should just be my username
  #       name << username
  #     elsif which_profile(other_user).last_name.nil? or which_profile(other_user).last_name.empty?
  #       #name should already be first_name and last_name is nil or blank.
  #       #So do nothing.
  #       #This truth statement is necessary so that it isn't clumped into the else action.
  #     else
  #       #oh but look at that! I have a first name and my last name is neither empty nor null!
  #       #So let's add the last_name to my name!
  #       name << ' ' << which_profile(other_user).last_name
  #     end
  #   #if a stranger is viewing my name...
  #   else
  #     name << username
  #   end
  #   return name
  # end

  #Returns the name of profile of the same ring the other_user is in
  def name(other_user)
    return self.which_profile(other_user).ring.projected_name
  end
  
  #Returns an array from 1 to the user's 'rings' preference 
  def ring_array
    ring_array = Array.new
    self.rings.count.times{|i| ring_array << i+1}
    return ring_array
  end
    
  #Given a ring, returns the profile of the user that is as far or the next farthest away.
  def next_closest_profile (ring_of_friend)
    #This method assumes that other_user is not the user and that other_user is a mutual friend
    #of the user.
    
    for ring_with_profile in self.rings.order('number ASC')
      unless ring_with_profile.profile.nil?
        if ring_with_profile.number >= ring_of_friend.number
          return ring_with_profile.profile
        end
      end
    end
    
    # #Set the profile to be published to initially be the public ring.
    # publish_ring = self.rings.count
    # #Go through each profile in self.
    # for profile in self.profiles
    #   #If a profile's ring is as far as or farther than the ring of the friendship and is closer than the current publish_ring
    #   if profile.ring >= friendship_ring and profile.ring < publish_ring
    #     #Reassign the publish_ring.
    #     publish_ring = profile.ring
    #   end
    # end
    # return self.profiles.find_by_ring(publish_ring)
  end

  #Returns the appropriate profile of the user to be seen by the other_person.
  def which_profile(other_user)
    #Currently runs two database queries to return the viewable profile of the other...can it be done faster/more efficiently?
    return self.next_closest_profile(self.which_ring(other_user))

    # if other_user == self
    #   return this_profile(1)
    # elsif is_mutual_friend?(other_user) == true  
    #   friendship_ring = self.which_ring(other_user)
    #   return this_profile(friendship_ring)
    # else
    #   return self.profiles.find_by_ring(self.preference.rings)
    # end
  end

  #Returns the friendship ring number of self that the other_user is in.
  def which_ring(other_user)
    #The user is considered to be in the zeroth ring CHANGED to ring 1
    if other_user == self
      return self.rings.find_by_number(1)
    #If the other_user is a mutual friend, just return the ring that friend is in.
    elsif self.mutual_friends.include?(other_user)
      return self.mutual_friendships.find_by_friend_id(other_user.id).ring
    #If the other_user is a stranger, return the public_ring number
    else
      # return self.preference.rings
      return self.public_ring
    end
  end

  private

  acts_as_authentic do |config|
    config.validate_login_field = false
    config.validate_password_field = false
  end
  
  def non_email_fields_blank_upon_creation
    self.username.blank? ? nil : self.errors.add(:username, 'must be blank')
    self.password.blank? ? nil : self.errors.add(:password, 'must be blank')
    self.password_confirmation.blank? ? nil : self.errors.add(:password_confirmation, 'must be blank')
    self.distinction.blank? ? nil : self.errors.add(:distinction, 'must be blank')
  end
  
end