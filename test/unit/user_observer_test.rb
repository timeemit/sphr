require 'test_helper'
require 'generators'

class UserObserverTest < ActiveSupport::TestCase
  test 'assocations created on build' do
    #After save, all associations should be empty except for preference, rings, profiles, cones
    user = skeleton1
    user.save
    
    #Make sure correct associations are empty
    assert user.friendships.empty?, 'nonempty friendships array after save'
    assert user.friends.empty?, 'nonempty friends array after save'
    assert user.inverse_friendships.empty?, 'nonempty inverse_friendships array after save'
    assert user.inverse_friends.empty?, 'nonempty inverse_friends array after save'    
    assert user.mutual_friendships.empty?, 'nonempty mutual_friendships array after save'
    assert user.mutual_friends.empty?, 'nonempty mutual_friends array after save'
    assert user.shoutouts.empty?, 'nonempty posts array after save'
    assert user.comments.empty?, 'nonempty comments array after save'
    
    assert !user.preference.nil?, 'preference still nil after save'
    assert user.preference.rings == 3, 'preference of ring number is not three'
    ring_pref = user.rings.count
    
    assert !user.rings.empty?, 'ring array still empty after save'
    assert user.rings.count == 3, 'number of user\'s rings is not equal to three'
    ring_pref.times {|i| assert user.rings.exists?(:number => i+1), "user does not have ring with number #{i+1}"}
    assert user.rings.find_by_public_ring(true).name == 'Public'

    assert !user.public_ring.nil?, 'public ring still nil after save'
    assert user.public_ring.number == ring_pref, 'public ring number not equal to user\'s preference of rings'
    assert user.public_ring.name == 'Public'

    assert !user.cones.empty?, 'cones array still empty after save'
    assert user.cones.find_by_name('Work'), 'no Work cone'
    assert user.cones.find_by_name('School'), 'no School cone'
    assert user.cones.find_by_name('Family'), 'no Family cone'
    
    assert !user.profiles.empty?, 'profiles array still empty after save'    
     
    assert !user.activities.empty?, 'activities array still empty after save'
    assert user.activities.size == 1, 'not just one activity for saved user'
    #This last assertion should be removed once Activities belong to only entitities.  Currently they also belong to rings, which is redundant.
    assert_same user.activities.last.entity, user.rings.find_by_number(ring_pref).profile, 'last (only) activity does not belong to public profile'
    
    assert user.activated, 'user is not activated after save'
  end
end