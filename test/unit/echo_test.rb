require 'test_helper'
require 'generators'

class EchoTest < ActiveSupport::TestCase
  test 'validates against blank echo' do
    assert !Echo.new.save
  end
  test 'validates presence of ring id' do
    user = saved_skeleton1
    count = user.rings.count
    ring = user.rings.find_by_number(rand(count) + 1)
    shoutout = ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    assert !Echo.new(:shoutout_id => shoutout.id).save
  end
  test 'validates presence of shoutout id' do
    user = saved_skeleton1
    count = user.rings.count
    ring = user.rings.find_by_number(rand(count) + 1)
    assert !ring.echoes.build.save
  end
  # test 'validates presence of signalled' do #signalled is always set regardless of parameters.  Use test 'set signalled before validation'
  #   user_setup
  #   friend_setup
  #   shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
  #   assert !Echo.new(:ring_id => @friend_ring.id, :shoutout_id => shoutout.id).save
  # end
  # test 'validates presence of distance' do #like signalled, distance is always set regardless of paramaters.  See vibration_test.rb
  # end
  test 'validates numericality of ring id' do
    user_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    friend_setup
    assert @friend_ring.echoes.build(:shoutout_id => shoutout.id).save
    # assert !Echo.new(:ring_id => @friend_ring.id + rand(), :shoutout_id => shoutout.id).save    Can't do this with attr_accessible set
  end
  test 'validates numericality of shoutout id' do
    user_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    friend_setup
    assert !@friend_ring.echoes.build(:shoutout_id => 0).save
    assert !@friend_ring.echoes.build(:shoutout_id => shoutout.id+rand()).save
  end
  test 'validates uniqueness of shoutout id' do
    user_setup
    friend_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo = @friend_ring.echoes.build(:shoutout_id => shoutout.id)
    
    assert echo.save, 'first echo did not save: ' + echo.errors.full_messages.inspect
    assert !@friend_ring.echoes.build(:shoutout_id => shoutout.id).save, 'second echo saved'
  end
  test 'validates within echo range' do
    
  end
  test 'validates no repeats by same user' do
    user_setup
    friend_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo1 = @friend_ring.echoes.build(:shoutout_id => shoutout.id)
    assert echo.save, 'echo1 did not save'
    echo2 = @friend_ring.echoes.build(:shoutout_id => shoutout.id)

  end
  test 'validates friendship necessary' do
    user_setup
    friend_setup
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo = @friend_ring.echoes.build(:shoutout_id => shoutout.id)
    assert echo.user == @friend, 'echo not associated to friend'
    assert !echo.user.mutual_friends.include?(shoutout.author), 'truth statement failed' 
    assert !echo.save, 'echo saved'
    mutual_friendship_setup
    assert echo.save, 'echo did not save'
  end
  
  test 'set distance before validation' do
    user_setup
    friend_setup
    others = build_skeletons(10, other)
    
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo = @friend_ring.echoes.build(:shoutout_id => shoutout.id)
    
    assert echo.save, 'errors: ' + echo.errors.full_messages.inspect
    assert echo.distance == 1
  end
  test 'set signalled before validation' do
    user_setup
    friend_setup
    
    shoutout = @user_ring.shoutouts.create(:content => 'Test1', :echo_range => -1)
    echo = @friend_ring.echoes.build(:shoutout_id => shoutout.id)
    assert echo.save, 'first echo did not save: ' + echo.errors.full_messages.inspect
    assert echo.signalled == false, 'signal was not false'
    
    shoutout = @user_ring.shoutouts.create(:content => 'Test2', :echo_range => -1)
    echo = @friend_ring.echoes.build(:shoutout_id => shoutout.id, :signalled => true)
    assert echo.save, 'second echo did not save: ' + echo.errors.full_messages.inspect
    assert echo.signalled == true, 'signal was not true'
  end

  test 'association to user' do
    user_setup
    friend_setup
    assert !@friend.id.blank?, 'friend not saved'
    assert !@friend_ring.id.blank?, 'friend ring not saved'
    shoutout = @user_ring.shoutouts.create(:content => 'Test', :echo_range => -1)
    echo = @friend_ring.echoes.build(:shoutout_id => shoutout.id)
    assert echo.save, 'echo did not save'
    # assert !echo.ring_id.blank?, 'ring_id is blank'
    # assert !echo.shoutout_id.blank?, 'shoutout_id is blank'
    # assert @friend_ring.user == @friend, 'friend ring to friend'
    # assert @friend_ring.echoes.last == echo, 'friend ring to echo'
    # assert @friend_ring.echoes.last.user == @friend, 'friend ring to echo to user'
    # assert @friend.echoes.last == echo, 'user to echo'
    assert echo.ring == @friend_ring, 'echo to ring'
    assert echo.ring.user == @friend, 'echo not associated through ring'
  
    assert echo.ring_id == @friend_ring.id, 'echo ring id not same'
    assert @friend_ring.user_id == @friend.id, 'ring user id not same'
  
    assert echo.user == @friend, 'echo to user'
    assert echo.user.ring == @friend_ring, 'echo to user to ring'
    # assert !echo.user.nil?, 'echo.user is nil'
  end
end