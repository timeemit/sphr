require 'test_helper'
require 'generators'

class FriendshipTest < ActiveSupport::TestCase
  test 'validates against blank friendship' do
    #A new friendship without any paramaters just shouldn't save.
    friendship = Friendship.new
    assert friendship.ring_id == nil, 'ring_id isn\'t nil'
    assert friendship.friend_id == nil, 'friend_id isn\'t nil'
    assert !friendship.save, 'friendship saved'
  end
  test 'validates against presence of friend_id' do
    #Two skeleton users are created and then friendships are extended from random rings between the users.
    #friend_id of each friendship is set to nil to test if the friendship will save.
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    ring_pref = users.first.rings.count
    2*ring_pref*ring_pref.times do
      ring = rand(ring_pref)+1
      friendship = build_skeleton_friendship(users.first.username, users.last.username, ring)
      friendship.friend_id = nil
      assert !friendship.save
      friendship.destroy
    end
  end
  test 'validates against presence of ring_id' do
    #Two skeleton users are created and then friendships are extended from random rings between the users.
    #user_id of each friendship is set to nil to test if the friendship will save.
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    ring_pref = users.first.rings.count
    2*ring_pref*ring_pref.times do
      ring = rand(ring_pref)+1
      friendship = build_skeleton_friendship(users.first.username, users.last.username, ring)
      friendship.ring_id = nil
      assert !friendship.save
      friendship.destroy
    end
  end
  test 'validates against self friendships' do
    user = skeleton1
    user.save
    ring_pref = user.rings.count
    2*ring_pref*ring_pref.times do
      ring = rand(ring_pref)+1
      friendship = build_skeleton_friendship(user.username, user.username, ring)
      assert_equal friendship.ring.user, friendship.friend, 'user and friend are not the same'
      assert !friendship.save
      friendship.destroy
    end
  end
  test 'validates for unique friendships' do
    #This test makes sure that multiple friendships cannot exist between two users
    users = build_skeletons(2, 'user')
    users.each {|u| u.save}
    friendship = build_skeleton_friendship(users.first.username, users.last.username, rand(users.first.rings.count)+1)
    assert friendship.save, 'first friendship did not save'
    friendship = nil
    users.first.rings.count.times do |i|
      friendship = build_skeleton_friendship(users.first.username, users.last.username, i+1)
      assert !friendship.save, 'friendship saved on ' + (i+1).ordinalize + ' ring'
      friendship.destroy
    end
  end
  test 'validates for static ' do
    
  end
  # test 'validates associated to valid ring' do
  #   ring = Ring.create
  #   friend = skeleton1.save
  #   friendship = Friendship.new(:ring_id => ring.id, :friend_id => friend.id, :mutual => :false)
  #   assert !friendship.save
  # end
  # test 'validates associated to valid friend' do
  # end
  
  test 'destroy proposal' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    ring_pref = users.first.rings.count
    2*ring_pref*ring_pref.times do |i|
      ring = rand(ring_pref)+1
      friendship = build_skeleton_friendship(users.first.username, users.last.username, ring)
      assert friendship.mutual == false, 'friendship proposal thinks it\'s mutual'
      assert friendship.save, 'friendship did not save on the ' + i.to_s + 'th round'
      assert friendship.destroy, 'friendship was not destroyed'
    end
  end
  test 'destroy mutual' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    ring_pref = users.first.rings.count
    2*ring_pref*ring_pref.times do |i|
      ring = rand(ring_pref)+1
      friendship1 = build_skeleton_friendship(users.first.username, users.last.username, ring)
      
      assert friendship1.save, 'first friendship did not save on the ' + i.to_s + 'th round'
      assert friendship1.mutual == false, 'first friendship thinks it is mutual.' + i.ordinalize + 'round'
      
      friendship2 = build_skeleton_friendship(users.last.username, users.first.username, ring)
      assert friendship2.save, 'second friendship did not save'
      
      assert friendship2.mutual == true, 'last friendship thinks it isn\'t mutual.' + i.ordinalize + 'round'
      assert friendship2.mutual_friendship.mutual == true
      #Although friendship2 has updated the physical record of friendship1 so that its mutual value is true,
      #friendzhip1 is an object and is not the record in the database so IT is not updated:
      assert !(friendship1.mutual == true), 'first friendship thinks it isn\'t mutual.' + i.ordinalize + 'round'
      
      assert friendship2.destroy, 'friendship2 could not be destroyed'
      assert !Friendship.exists?(friendship1.id), 'friendship1 was not destroyed'

      ring = nil
      friendships = nil
    end
  end
  
  test 'method mutual_exists?, mutual_friendship, and make_mutual' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    
    friendzhip0 = build_skeleton_friendship('user0', 'user1', rand(users.first.rings.count)+1)
    
    assert friendzhip0.mutual == false, 'friendzhip0 thinks it is mutual before building friendzhip1'
    assert !friendzhip0.mutual_exists?, 'friendzhip0 thinks there is a mutual copy before building friendzhip1'
    assert friendzhip0.mutual_friendship.nil?, 'friendzhip0 was able to find a mutual copy before building friendzhip1'
    
    friendzhip1 = build_skeleton_friendship('user1', 'user0', rand(users.last.rings.count)+1)
    
    assert friendzhip0.mutual == false, 'friendzhip0 thinks it is mutual after building friendzhip1'
    assert !friendzhip0.mutual_exists?, 'friendzhip0 thinks there is a mutual copy after building friendzhip1'
    assert friendzhip0.mutual_friendship.nil?, 'friendzhip0 was able to find a mutual copy after building friendzhip1'
    assert friendzhip1.mutual == false, 'friendzhip1 thinks it is mutual after building friendzhip1'
    assert !friendzhip1.mutual_exists?, 'friendzhip1 thinks there is a mutual copy after building friendzhip1'
    assert friendzhip1.mutual_friendship.nil?, 'friendzhip1 was able to find a mutual copy after building friendzhip1'
    
    assert friendzhip0.save, 'friendzhip0 did not save'
    
    assert friendzhip0.mutual == false, 'friendzhip0 thinks it is mutual after saving friendzhip0'
    assert !friendzhip0.mutual_exists?, 'friendzhip0 thinks there is a mutual copy after saving friendzhip0'
    assert friendzhip0.mutual_friendship.nil?, 'friendzhip0 was able to find a mutual copy after saving friendzhip0'
    assert friendzhip1.mutual == false, 'friendzhip1 thinks it is mutual after saving friendzhip0'
    assert friendzhip1.mutual_exists?, 'friendzhip1 doesn\'t think there is a mutual copy after saving friendzhip0'
    assert_equal friendzhip1.mutual_friendship, friendzhip0, 'friendzhip1 was unable to find a mutual copy after saving friendzhip0'
    
    assert friendzhip1.save, 'friendzhip1 did not save'
    
    assert friendzhip1.mutual == true, 'friendzhip1 doesn\'t think it is mutual after saving friendzhip1'
    assert friendzhip1.mutual_exists?, 'friendzhip1 doesn\'t think there is a mutual copy after saving friendzhip1'
    assert friendzhip1.mutual_friendship.mutual == true, 'friendzhip1 didn\'t update the mutual boolean of its mutual friendship'

    #Although friendzhip1 has updated the physical record of friendzhip0 so that its mutual value is true,
    #friendzhip0 is an object and is not the record in the database so IT is not updated.
    assert_equal friendzhip1.mutual_friendship, friendzhip0, 'friendzhip1 was able to find a mutual copy after saving friendzhip1'
    assert friendzhip0.mutual == false, 'unupdated friendzhip0 thinks it isn\'t mutual after saving friendzhip1'
    assert_not_equal friendzhip1.mutual_friendship.mutual, friendzhip0.mutual, 'unupdated friendzhip0 has a mutual_friendship whose mutual boolean is the same as friendship0'
    
    #But since the ring_id and friend_id of friendzhip0 are still unchanged, mutual_exists? and mutual_friendship methods should still work
    assert friendzhip0.mutual_exists?, 'unupdated friendzhip0 doesn\'t  think there is a mutual copy after saving friendzhip1'
    assert_equal friendzhip0.mutual_friendship, friendzhip1, 'unupdated friendzhip0 was unable to find a mutual copy after saving friendzhip1'
    
    #To update friendzhip0, the active record object must be reloaded.
    friendzhip0 = Friendship.find(friendzhip0.id)
    assert friendzhip0.mutual == true, 'updated friendzhip0 doesn\'t think it is mutual after saving friendzhip1'
    assert friendzhip0.mutual_exists?, 'updated friendzhip0 doesn\'t  think there is a mutual copy after saving friendzhip1'
    assert_equal friendzhip0.mutual_friendship, friendzhip1, 'updated friendzhip0 was unable to find a mutual copy after saving friendzhip1'
  end
  
  test 'skeleton friendship builder' do
    #Creates 5 users and and randomly creates a friendship proposal between two of them 50 times times
    #Makes sure that friendships aren't created to and from the same user and that associations are correct.
    #Also ensures that the friendship's mutual boolean attribute is labeled false.
    number_of_users = 5
    users = build_skeletons(number_of_users, 'user')
    users.each{|u| u.save}
    2*number_of_users*number_of_users.times do
      ring = rand(users.first.rings.count)+1
      assert ring <= users.first.rings.count, 'ring is greater than preference of rings'
      user_name_id = rand(number_of_users)
      friend_name_id = rand(number_of_users)
      assert friendship = build_skeleton_friendship('user' + user_name_id.to_s, 'user' + friend_name_id.to_s, ring)
      if user_name_id == friend_name_id
        assert !friendship.save, 'friendship did not save when '
      else
        assert !friendship.nil?, 'created friendship is nil'
        assert friendship.friend_id.integer?, 'friend_id is nil'
        assert friendship.ring_id.integer?, 'ring_id is nil'
        assert friendship.mutual == false, 'friendship is mutual when it shouldn\'t be'

        assert friendship.save!, 'friendship did not save'
        assert friendship.friend == users[friend_name_id], 'friendship is not between users'
        assert friendship.ring == users[user_name_id].rings.find_by_number(ring), 'friendship disjoint from ring'
      end
            
      ring = nil
      user_name_id = nil
      friend_name_id = nil
      friendship.destroy
    end
  end
  test 'skeleton mutual friendship builder' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    100.times do
      ring = rand(users.first.rings.count)+1
      
      friendships = build_skeleton_mutual_friendship('user0', 'user1', ring)
      
      assert !friendships.empty?, 'no friendships created'
      
      assert !friendships.first.nil?, 'first created friendship is nil'
      assert !friendships.last.nil?, 'last created friendship is nil'
      
      assert_not_same friendships.first, friendships.last, 'only one friendship created'
      
      assert friendships.first.friend_id.integer?, 'first friend_id is nil'
      assert friendships.last.friend_id.integer?, 'last friend_id is nil'
      
      assert friendships.first.friend == users.last, 'first friendship does not extend to last user'
      assert friendships.last.friend == users.first, 'last friendship does not extend to first user'
      
      assert friendships.first.ring_id.integer?, 'first ring_id is nil'
      assert friendships.last.ring_id.integer?, 'last ring_id is nil'
      
      assert friendships.first.ring.number <= users.first.rings.count, 'first friendship ring is greater than preference of rings for first user'
      assert friendships.last.ring.number <= users.last.rings.count, 'last friendship ring is greater than preference of rings for last user'
      
      assert friendships.first.ring == users.first.rings.find_by_number(ring), 'first friendship disjoint from first user\'s ring'
      assert friendships.last.ring == users.last.rings.find_by_number(ring), 'last friendship disjoint from last user\'s ring'
      
      friendships.each{|f| assert f.save, 'friendship did not save'}      
      assert_equal friendships.first.mutual_friendship, friendships.last, 'failure of first.mutual_friendship method'
      assert_equal friendships.last.mutual_friendship, friendships.first, 'failure of last.mutual_friendship method'
      assert friendships.last.mutual == true, 'last friendship is not mutual'
      assert !friendships.first.mutual == true, 'first friendship is not mutual'
      assert friendships.first.reload.mutual == true, 'first friendship is not mutual'
      
      friendships.first.destroy
      assert !Friendship.exists?(friendships.last)
    end
  end
  
  test 'user method friend of friends' do
    
  end
  
  #The following three methods have been deprecated, so tests haven't been written for them.
  test 'user method friend is?' do
    
  end
  test 'user method friendship_with' do
    
  end
  test 'user method is_mutual_friend?' do
  
  end
        
  test 'associations of user to friendships and to friends' do
    user = skeleton1
    user.save
    friendz = build_skeletons(3, 'friend')
    friendz.each{|f| f.save}
    friendzhips = Array.new
    friendz.each do |friend|
      friendzhips << build_skeleton_friendship(user.username, friend.username, rand(user.rings.count)+1)
      friendzhips.last.save
    end
    assert friendz.count == friendzhips.count, 'unequal friendz and friendzhips'
    assert friendz.count == friendzhips.uniq.count, 'duplicate friendz exist'
    friendzhips.each do |friendzhip| 
      assert friendzhip.id != nil, 'friendzhip did not save to database'
      assert friendzhip.friend.id != nil, 'friendzhip.friend did not save to database'
      assert user != friendzhip.friend, 'friendzhip.friend is user'
      assert friendz.include?(friendzhip.friend), 'friendzhip.friend is not in friendz'
      
      assert user.rings.exists?(friendzhip.ring_id), 'user does not have the ring that friendzhip is associated to'
      assert friendz.include?(friendzhip.friend), 'friendz does not include friend of friendzhip'
      assert friendzhip.mutual == false, 'friendzhip thinks it is mutual'

      assert !user.friendships.empty?, 'friendships of user is empty'
      assert user.friendships.exists?(friendzhip), 'friendzhip not found in friendships of user'
      
      assert user.friends.nil? == false, 'friends of user is nil'
      assert user.friends.empty? == false, 'friends of user is empty' #CANNOT GET THIS TO WORK!!!!
      assert user.friends.include?(friendzhip.friend), 'friendzhip.friend not found in friends of user'
    end
    assert user.inverse_friendships.empty?, 'non-empty inverse friendships'
    assert user.inverse_friends.empty?, 'non-empty inverse friends'
    assert user.mutual_friendships.empty?, 'non-empty mutual friendships'
    assert user.mutual_friends.empty?, 'non-empty mutual friends'
    assert user.inverse_mutual_friendships.empty?, 'non-empty inverse mutual friendships'
  end    
  test 'associations of user to inverse_friendships and to inverse_friends' do
    user = skeleton1
    user.save
    inverse_friendz = build_skeletons(3, 'friend')
    inverse_friendz.each{|f| f.save}
    friendzhips = Array.new
    inverse_friendz.each do |friend|
      friendzhips << build_skeleton_friendship(friend.username, user.username, rand(user.rings.count)+1)
      friendzhips.last.save
    end
    friendzhips.each do |friendzhip| 
      assert_equal friendzhip.friend, user, 'friendzhip is not proposed to the user'
      assert inverse_friendz.include?(friendzhip.ring.user), 'friendship is not extended from the inverse_friendz'
      assert friendzhip.mutual == false, 'friendzhip thinks that it is mutual'
      
      assert !user.inverse_friendships.empty?, 'empty inverse_friendships'
      assert user.inverse_friendships.exists?(friendzhip), 'incomplete association to inverse_friendships'
      assert !user.inverse_friends.empty?, 'empty inverse_friends'
      assert user.inverse_friends.include?(friendzhip.ring.user), 'incomplete association to invere_friends'
    end
    assert user.friendships.empty?, 'non-empty friendships'
    assert user.friends.empty?, 'non-empty friends'
    assert user.mutual_friendships.empty?, 'non-empty mutual friendships'
    assert user.mutual_friends.empty?, 'non-empty mutual friends'
    assert user.inverse_mutual_friendships.empty?, 'non-empty inverse mutual friendships'
  end
  test 'associations of user to mutual_friendships, to mutual_friends, inverse_mutual_friendships, and accessed_rings' do
    user = skeleton1
    user.save
    friendz = build_skeletons(3, 'friend')
    friendz.each{|f| f.save}
    mutual_friendzhips = Array.new
    friendz.each do |friend|
      mutual_friendzhips << build_skeleton_mutual_friendship(user.username, friend.username, rand(user.rings.count)+1)
      mutual_friendzhips.last.each{|a| a.save}
    end

    assert !user.mutual_friends.empty?, 'mutual_friends is empty'
    assert !user.inverse_mutual_friendships.empty?, 'inverse_mutual_friends is empty'
    
    mutual_friendzhips.each do |mutual_friendzhip| 
      assert user.mutual_friendships.exists?(mutual_friendzhip.first), 'mutual_friendships incorrectly associated'
      assert user.mutual_friends.include?(mutual_friendzhip.first.friend), 'mutual_friends incorrectly associated'

      assert user.inverse_mutual_friendships.exists?(mutual_friendzhip.last), 'inverse_mutual_friendships incorrectly associated'
      assert user.inverse_mutual_friendships.find(mutual_friendzhip.last).friend == user, 'inverse_mutual_friendship not directed towards user'

      assert_equal user.inverse_mutual_friendships.find(mutual_friendzhip.last).user,
        user.mutual_friendships.find(mutual_friendzhip.first).friend, 'inverse_mutual_friendships is not the inverse of mutual_friendships'''
        'inverse_mutual_friendship not directed towards user'
    end
    assert user.friendships.empty?, 'non-empty friendships'
    assert user.friends.empty?, 'non-empty friends'
    assert user.inverse_friendships.empty?, 'non-empty inverse friendships'
    assert user.inverse_friends.empty?, 'non-empty inverse friends'
  end
  #HASN'T BEEN FINISHED
  # test 'association to friend_friendships and friend_mutual_friendships' do
  #   #A friendship will extend from user1 to user2 will be used to find friendships from user2 to friendz and mutual_friendz 
  #   user1 = skeleton1 
  #   user1.save
  #   user2 = skeleton2 
  #   user2.save
  #   friendz = build_skeletons(3, 'friendz')
  #   friendz.each{|u| u.save}
  #   mutual_friendz = build_skeletons(3,'mutual_friendz')
  #   mutual_friendz.each{|u| u.save}
  #   
  #   base_friendzhip = build_skeleton_friendship(user1.username, user2.username, rand(user1.rings.count)+1)
  #   assert base_friendzhip.save, 'base_friendzhip did not save'
  #   assert base_friendzhip.friend_friendships.empty?, 'friend_friendships not empty before creating friendzhips'
  #   assert base_friendzhips.friend_mutual_frienships.empty?, 'friend_mutual_friendships not empty before creating mutual_friendzhips'
  #   
  #   friendzhips = Array.new
  #   friendz.each do |friend|
  #     friendzhips << build_skeleton_friendship(user2.username, friend.username, rand(user2.rings.count))
  #     assert friendzhips.last.save, 'friendzhip did not save for ' + friend.username
  #     assert base_friendzhip.friend_friendships.exists?(friendzhips.last), 'friend_friendships does not include ' + friend.username
  #     assert_same base_friendzhip.friend_friendships.find_by_friend_id(friendzhips.last.friendship_id), friendzhips.last
  #   end
  #   
  #   #MUST WRITE THE FOLLOWING
  #   #Finally, the friendship between user1 and user2 will become mutual to test if they can be obtained quickly
  # end
  test 'association to user' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    friendzhip = build_skeleton_friendship(users.first.username, users.last.username, rand(users.first.rings.count)+1)
    assert friendzhip.save, 'friendzhip did not save'
    assert_equal users.first, friendzhip.user, 'friendzhip did not associate to user'
  end
  test 'association to profile' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}

    user = users.first
    friend = users.last
    ring_pref = user.rings.count

    #Test to see if the public profile can be accessed through an inverse_mutual_friendship

    friendzhips = build_skeleton_mutual_friendship(user.username, friend.username, ring_pref)
    friendzhips.each{|f| assert f.save, 'public friendzhip did not save, errors: ' + f.errors.full_messages.inspect}
    friendzhips.each{|f| f.reload}
    
    friend_ring = friend.public_ring
    assert friend.rings.exists?(friend_ring)
    assert user.inverse_mutual_friendships.exists?(:ring_id => friend_ring.id), 'inverse_mutual_friendship could not be found, ring: ' + friend_ring.number.to_s
    assert_equal user.inverse_mutual_friendships(true).find_by_ring_id(friend_ring).profile, friend.public_ring.profile, 'fetched profile not equal to set profile' # + user.inverse_mutual_friendships.find_by_ring_id(friend_ring).profile.inspect
    
    assert friendzhips.first.destroy, 'first was not destroyed' #Should also destroy friendzhips.last
    assert !Friendship.exists?(friendzhips.first), 'first friendship did not delete'
    assert !Friendship.exists?(friendzhips.last), 'last friendship did not delete'
    
    friend_ring = nil
    
    #Profile is now randomly added to each ring that is not the public profile
    (2*ring_pref**2).times do |i|
      ring_number = rand(ring_pref-1)+1

      friendzhips = build_skeleton_mutual_friendship(user.username, friend.username, ring_number) 
      friendzhips.each{|f| assert f.save, 'friendzhip did not save, errors: ' + f.errors.full_messages.inspect}
      friendzhips.each{|f| f.reload}

      profile = friend.rings.find_by_number(ring_number).create_profile

      assert !profile.nil?, 'profile is nil, round ' + i.to_s
      
      friend_ring = friend.rings.find_by_number(ring_number)
      assert friend.rings.exists?(friend_ring)
      assert user.inverse_mutual_friendships.exists?(:ring_id => friend_ring.id), 'inverse_mutual_friendship could not be found, ring: ' + friend_ring.number.to_s
      assert_equal user.inverse_mutual_friendships(true).find_by_ring_id(friend_ring).profile, profile, 'fetched profile not equal to set profile' # + user.inverse_mutual_friendships.find_by_ring_id(friend_ring).profile.inspect

      profile.destroy #Profile shouldn't be public, so this isn't a problem
      assert friendzhips.first.destroy, 'first was not destroyed' #Should also destroy friendzhips.last
      assert !Friendship.exists?(friendzhips.first), 'first friendship did not delete'
      assert !Friendship.exists?(friendzhips.last), 'last friendship did not delete'
      
      friend_ring = nil
    end
  end
end