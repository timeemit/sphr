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
    assert !ring.shoutouts.build(:content => 'Test', :echo_range => 0 + rand()).save, 'rand() saved'
    assert !ring.shoutouts.build(:content => 'Test1', :echo_range => -2).save, '-2 saved'
    shoutout = ring.shoutouts.build(:content => 'Test2', :echo_range => -1)
    assert shoutout.save, '-1 did not save: ' + shoutout.errors.full_messages.inspect
  end
  test 'validates uniqueness of content' do
    user = saved_skeleton1
    rings_pref = user.rings.count
    ring = user.rings.find_by_number(rand(rings_pref) + 1)
    assert ring.shoutouts.build(:content => 'Test', :echo_range => 0).save
    assert !ring.shoutouts.build(:content => 'Test', :echo_range => 0).save
  end

  test 'association to ring and user' do
    user = saved_skeleton1
    assert !user.rings.empty?, 'user rings are empty'
    rings_pref = user.rings.count
    ring = user.rings.find_by_number(rand(rings_pref) + 1)
    assert !ring.nil?, 'ring is nil'
    shoutout = ring.shoutouts.create(:content => 'Hello World', :echo_range => 0)
    assert !shoutout.nil?, 'shoutout is nil'
    assert shoutout.ring == ring, 'shoutout is not associated to ring'
    assert_equal shoutout.author, user, 'shoutout is not associated to user'
  end
end
