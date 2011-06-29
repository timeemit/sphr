require 'test_helper'
require 'generators'

class VibrationTest < ActiveSupport::TestCase
  test 'validates against blank vibration' do
    assert !Vibration.new.save
  end
  test 'validates against blank parent id' do
    user_setup
    friend_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo = @friend_ring.echoes.create(:shoutout_id => shoutout.id)
    assert !echo.vibrations.build.save
  end
  test 'validates no self echo' do
    #An echo should not be it's own parent.
    user_setup
    friend_setup

    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo = @friend_ring.echoes.create(:shoutout_id => shoutout.id)
    assert echo.children.empty?, 'nonempty children before update'
    assert echo.update_attributes(:vibration_attributes => {:parent_id => echo.id, :child_id => echo.id}), 'did not update'
    assert echo.children.empty?, 'nonempty children'
  end

  test 'works as intended' do
    user_setup
    friends = build_skeletons(2, 'Friend')
    friendships = Array.new
    friends.each do |f| 
      assert f.save, 'friend did not save'
      friendships << saved_skeleton_mutual_friendship(@user, f, @user_ring.number)
    end
    
    count0 = friends.first.rings.count
    ring0 = friends.first.rings.find_by_number(rand(count0) + 1)
    assert !ring0.nil?, 'ring0 is nil'
    
    count1 = friends.last.rings.count
    ring1 = friends.last.rings.find_by_number(ring0.number)
    assert !ring1.nil?, 'ring1 is nil'
    
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo1 = ring0.echoes.build(:shoutout_id => shoutout.id)
    assert echo1.save, 'echo1 did not save: ' + echo1.errors.full_messages.inspect
    assert echo1.ring == ring0, 'echo1 is not directly associated to @user_ring'
    echo2 = ring1.echoes.build(:shoutout_id => shoutout.id)
    assert echo2.save, 'echo2 did not save: ' + echo2.errors.full_messages.inspect
    assert echo2.ring == ring1, 'echo2 is not directly associated to @friend_ring'
    assert echo2.update_attributes(:vibration_attributes => {:parent_id => echo1.id, :child_id => echo2.id}), 'echo2 did not update'
    
    assert !echo2.vibration.nil?, 'nil vibration for echo2'
    assert echo1.vibrations.size > 0, 'echo1 has zero vibrations'
    assert echo1.vibrations.size == 1, 'echo1 has more than one vibration'
    assert echo1.vibrations.first == echo2.vibration, 'echoes do not share a vibration'
    assert echo2.vibration.parent == echo1, 'vibration parent is not echo1'
    assert echo2.parent == echo1, 'echo1 is not the parent of echo2'
    assert echo1.children.exists?(echo2), 'echo2 is not the child of echo1'
    assert echo1.distance == 1
    assert echo2.distance == 2
    assert !echo1.ring.user.nil?, 'echo1 ring user is nil'
    assert !echo2.ring.user.nil?, 'echo2 ring user is nil'
    assert friends.include?(echo1.ring.user), 'friends does not recognize the user of ring of echo1'
    assert friends.include?(echo2.ring.user), 'friends does not recognize the user of ring of echo2'    
    assert !echo1.user.nil?, 'echo1 user is nil'
    assert !echo2.user.nil?, 'echo2 user is nil'
    assert echo1.ring.user == echo1.user, 'echo1 is incorrectly associated with user'
    assert echo2.ring.user == echo2.user, 'echo2 is incorrectly associated with user'
    assert friends.include?(echo1.user), 'friends does not recognize the user of echo1'
    assert friends.include?(echo2.user), 'friends does not recognize the user of echo2'    
  end
  test 'echo distance' do
    user_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
 
    echo_count = shoutout.echoes.size
    assert echo_count == 0, 'initial echo_count is wrong'
    echo = nil
    
    friendships = Array.new
    
    friends = build_skeletons(100, 'Friend')
    friends.each do |f| 
      assert f.save, 'friend did not save'
      friendships << saved_skeleton_mutual_friendship(@user, f, @user_ring.number)      
      
      count = f.rings.count
      ring = f.rings.find_by_number(rand(count) + 1)
      assert !ring.nil?, 'f.ring is nil'
       
      new_echo = ring.echoes.build(:shoutout_id => shoutout.id)
      assert new_echo.save, 'echo did not save: ' + new_echo.errors.full_messages.inspect
      if echo.nil?
        assert new_echo.distance == echo_count + 1, 'new echo is not echo count'
        echo_count += 1
        assert echo_count == 1, 'echo count is not 1'
        echo = new_echo
        next
      end

      assert new_echo.update_attributes(:vibration_attributes => {:parent_id => echo.id, :child_id => new_echo.id}), 'new_echo did not update'
      assert !new_echo.vibration.nil?, 'nil vibration for new_echo'
      assert echo.vibrations.size > 0, 'echo has zero vibrations'
      assert echo.vibrations.size == 1, 'echo has more than one vibration'
      assert echo.vibrations.first == new_echo.vibration, 'echoes do not share a vibration'
      assert new_echo.vibration.parent == echo, 'vibration parent is not echo'
      assert new_echo.parent == echo, 'echo is not the parent of new_echo'
      assert echo.children.exists?(new_echo), 'new_echo is not the child of echo'
   
      assert echo.distance == echo_count, 'wrong echo distance'
      assert new_echo.distance == echo_count + 1, 'wrong new echo distance'
      echo_count += 1
      assert friends.include?(echo.user), 'friends does not recognize the user of echo'
      assert friends.include?(new_echo.user), 'friends does not recognize the user of new_echo'
   
      echo = new_echo
    end
  end
end