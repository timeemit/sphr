#tests for skeleton1 and skeleton2 are in user_test.rb
def new_skeleton1
  return User.new(:email => 'a1@b.com', :email_confirmation => 'a1@b.com')
end
def skeleton1
  user = new_skeleton1
  user.save
  user.confirm!
  user.username = 'NotBlank1'
  user.password = 'S1lly'
  user.password_confirmation = 'S1lly'
  user.distinction = 'Skeleton1'
  return user
end
def saved_skeleton1
  user = skeleton1
  user.save
  return user
end
def skeleton2
  user = User.create(:email => 'a2@b.com', :email_confirmation => 'a2@b.com')
  user.confirm!
  user.username = 'NotBlank2'
  user.password = 'S1lly'
  user.password_confirmation = 'S1lly'
  user.distinction = 'Skeleton2'
  return user
end
def saved_skeleton2
  user = skeleton2
  user.save
  return user
end

#Builds 'number' of users with username 'username' + index.  Returns all the new users in an array
def build_skeletons(number, username)
  skelly_array = Array.new
  number.times do |index|
    user = User.create(
      :email => username + index.to_s + '@frndsphr.com',
      :email_confirmation => username + index.to_s + '@frndsphr.com')
    user.confirm!
    user.username = username + index.to_s
    user.password = 'Sk3lly'
    user.password_confirmation = 'Sk3lly'
    user.distinction = 'I am ' + username + index.to_s
    skelly_array << user
  end
  return skelly_array
end
#Builds a friendship from the one with username 'user1' to the one with username 'user2' in user1's 'ring'
def build_skeleton_friendship(user1, user2, ring)
  User.find_by_username(user2).inverse_friendships.build(
    :ring_id => User.find_by_username(user1).rings.find_by_number(ring).id,
    :message => "From #{User.find_by_username(user1).username}", 
    :note => "To #{User.find_by_username(user2).username}")
  # User.find_by_username(user1).rings.find_by_number(ring).friendships.new(
  #   :friend_id => User.find_by_username(user2).id, 
  #   :message => "From #{User.find_by_username(user1).username}", 
  #   :note => "To #{User.find_by_username(user2).username}")
end
#Builds two reciprocating friendships between users with usernames 'user1' and 'user2' in 'ring'.
def build_skeleton_mutual_friendship(user1, user2, ring)
  friendships = Array.new
  friendships << build_skeleton_friendship(user1, user2, ring)
  friendships << build_skeleton_friendship(user2, user1, ring)
  return friendships
end
#Creates a friendship between users user1 and user2 through ring_number.
def saved_skeleton_friendship(user1, user2, ring_number)
  return user2.inverse_friendships.create(
    :ring_id => user1.rings.find_by_number(ring_number).id,
    :message => "From #{user1.username}", 
    :note => "To #{user2.username}")
end
#Creates two reciprocating friendships between users user1 and user2 through ring_nmber
def saved_skeleton_mutual_friendship(user1, user2, ring_number)
  friendships = Array.new
  friendships << saved_skeleton_friendship(user1, user2, ring_number)
  friendships << saved_skeleton_friendship(user2, user1, ring_number)
  return friendships
end
#Specifies instance variables for user, user_count, and user_ring
def user_setup
  @user = saved_skeleton1
  @user_count = @user.rings.count
  @user_ring = @user.rings.find_by_number(rand(@user_count) + 1)
end
#Specifies instance variables for friend, friend_count, and Friend_ring
def friend_setup
  @friend = saved_skeleton2
  @friend_count = @friend.rings.count
  @friend_ring = @friend.rings.find_by_number(rand(@friend_count) + 1)
end
#Specifies instance variables for friendship_forward and friendship backward for @user and @friend through ring
def mutual_friendship_setup(ring_number)
  @friendship_forward = saved_skeleton_friendship(@user, @friend, ring_number)
  @friendship_backward = saved_skeleton_friendship(@friend, @user, ring_number)
end

#Tests for create_skeletons, create_skeleton_friendship, and create_skeleton_mutual_friendship
# are in friendship_test.rb
