require 'test_helper'
require 'generators'
class ShoutoutTest < ActiveSupport::TestCase
  test 'validates presesence of content' do
    user = saved_skeleton1
    rings_pref = user.rings.count
    ring = user.rings.find_by_number(rand(rings_pref) + 1)
    assert !ring.shoutouts.build(:content => nil, :echo_range => 0).save
    assert !ring.shoutouts.build(:content => '', :echo_range => 0).save
  end
  test 'validates presence of echo_range' do
    user = saved_skeleton1
    rings_pref = user.rings.count
    ring = user.rings.find_by_number(rand(rings_pref) + 1)
    assert !ring.shoutouts.build(:content => 'Test', :echo_range => nil).save
  end
  test 'validates echo_range is an integer greater than or equal to -1' do
    user = saved_skeleton1
    rings_pref = user.rings.count
    ring = user.rings.find_by_number(rand(rings_pref) + 1)
    assert !user.authored_shoutouts.build(:ring_id => ring.id, :content => 'Test', :echo_range => 0 + rand()).save, 'saved a noninteger'
    assert !user.authored_shoutouts.build(:ring_id => ring.id, :content => 'Test1', :echo_range => -2).save, '-2 saved'
    shoutout = user.authored_shoutouts.build(:ring_id => ring.id, :content => 'Test2', :echo_range => -1)
    assert shoutout.save, '-1 did not save: ' + shoutout.errors.full_messages.inspect
  end
  test 'validates uniqueness of content' do
    user = saved_skeleton1
    rings_pref = user.rings.count
    ring = user.rings.find_by_number(rand(rings_pref) + 1)
    assert user.authored_shoutouts.build(:ring_id => ring.id, :content => 'Test', :echo_range => 0).save
    assert !user.authored_shoutouts.build(:ring_id => ring.id, :content => 'Test', :echo_range => 0).save
  end

  test 'association to ring, author, and user' do
    user1 = saved_skeleton1
    assert !user1.rings.empty?, 'user rings are empty'
    rings_pref_1 = user1.rings.count
    ring_1 = user1.rings.find_by_number(rand(rings_pref_1) + 1)
    assert !ring_1.id.nil?, 'ring 1 is nil'
    
    user2 = saved_skeleton2
    assert !user2.rings.empty?, 'user rings are empty'
    rings_pref_2 = user2.rings.count
    ring_2 = user2.rings.find_by_number(rand(rings_pref_2) + 1)
    assert !ring_2.id.nil?, 'ring 2 is nil'
    
    shoutout = user1.authored_shoutouts.build(:ring_id => ring_2.id, :content => 'Hello World', :echo_range => 0)
    assert shoutout.save, 'shoutout did not save'
    assert shoutout.ring == ring_2, 'shoutout is not associated to ring'
    assert shoutout.user == user2, 'shoutout does not belong to the user'
    assert shoutout.author == user1, 'user is not the author of the shoutout'
  end
end
