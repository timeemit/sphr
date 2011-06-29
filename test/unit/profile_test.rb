require 'test_helper'
require 'generators'

class ProfileTest < ActiveSupport::TestCase
  test 'blank profile' do
    assert !Profile.new.save
  end
  # test 'validates presence of ring_id' do
  #   user = skeleton1
  #   user.save
  #   assert !user.profiles.first.update_attributes(:ring_id => nil)
  # end
  test 'validates uniqueness of ring_id' do
    user = skeleton1
    user.save
    (user.rings.count-1).times do |i|
      assert user.rings.find_by_number(i+1).create_profile, 'could not create profile, i = ' + i.to_s
    end
    user.rings.order('number ASC').each do |ring|
      assert !ring.profile.nil?, 'nil profile, number = ' + ring.number.to_s
      assert !ring.build_profile.save, 'could create profile, number = ' + ring.number.to_s
    end
  end
  #WRITE THESE TESTS!
  test 'vaildate format of first_name' do
    
  end
  test 'validate format of last_name' do
    
  end

  test 'association to ring' do
    profile = Profile.create
    assert profile.user.nil?
  end
  test 'association to user' do
    user = skeleton1
    user.save
    assert user == user.public_ring.user
  end
  test 'association of user to public profile' do
    user = skeleton1
    user.save
    assert user.public_profile == user.public_ring.profile
  end
  
  test 'method projected name' do
    user = skeleton1
    #Four cases: Neither first or last name present, both first and last name present, first but not last name present, last but not first name present
    user.save
    user.rings.create(:number => 1, :name => 'Extra')
    assert user.rings.count == 4
    
    assert user.rings.find_by_number(1).build_profile(:first_name => 'A', :last_name => 'B').save, 'ring 1 did not save'
    assert user.rings.find_by_number(2).build_profile(:first_name => 'A').save, 'ring 2 did not save'
    assert user.rings.find_by_number(3).build_profile(:last_name => 'B').save, 'ring 3 did not save'

    assert user.rings.find_by_number(1).profile.first_name == 'A', 'ring 1 first name is wrong'
    assert user.rings.find_by_number(1).profile.last_name == 'B', 'ring 1 last name is a value'
    assert user.rings.find_by_number(2).profile.first_name == 'A', 'ring 2 first name is a value'
    assert user.rings.find_by_number(2).profile.last_name.blank?, 'ring 2 last name is a value'
    assert user.rings.find_by_number(3).profile.first_name.blank?, 'ring 3 first name is a value'
    assert user.rings.find_by_number(3).profile.last_name == 'B', 'ring 3 last name is a value'
    assert user.rings.find_by_number(4).profile.first_name.blank?, 'ring 3 first name is a value'
    assert user.rings.find_by_number(4).profile.last_name.blank?, 'ring 3 last name is a value'

    profile = user.rings.find_by_number(1).profile
    assert profile.ring.projected_name == profile.first_name + ' ' + profile.last_name, 'ring 1 projected_name is wrong'
    profile = user.rings.find_by_number(2).profile
    assert profile.ring.projected_name == profile.first_name, 'ring 2 projected_name is wrong'
    profile = user.rings.find_by_number(3).profile
    assert profile.ring.projected_name == profile.last_name, 'ring 3 projected_name is wrong'
    profile = user.rings.find_by_number(4).profile
    assert profile.ring.projected_name == user.username, 'ring 4 projected_name is wrong'
  end
  test 'user method next_closest_profile' do
    user = skeleton1
    user.save
    assert user.rings.count == 3
    #Test with only a public profile, one profile in the second then in the third ring, and then one in every profile
    3.times do |i| 
      assert user.next_closest_profile(user.rings.find_by_number(i+1)) == user.public_ring.profile, '1 @ 3 not public profile i = ' + i.to_s
    end
    
    new_profile = user.rings.find_by_number(2).create_profile
    2.times do |i|
      assert user.next_closest_profile(user.rings.find_by_number(i+1)) == user.rings.find_by_number(2).profile, '2 @ 2 & 3 not ring 2 profile i = ' + i.to_s
    end
    assert user.next_closest_profile(user.public_ring) == user.public_ring.profile, '2 @ 2 & 3 not ring public profile'
    
    new_profile.update_attribute(:ring_id, user.rings.find_by_number(1).id)
    assert user.next_closest_profile(user.rings.find_by_number(1)) == user.rings.find_by_number(1).profile, '2 @ 1 & 3 not ring 1 profile'
    2.times do |i|
      assert user.next_closest_profile(user.rings.find_by_number(i+2)) == user.public_ring.profile, '2 @ 1 & 3 not public ring profile i = ' + i.to_s
    end
    
    user.rings.find_by_number(2).create_profile
    3.times do |i|
      assert user.next_closest_profile(user.rings.find_by_number(i+1)) == user.rings.find_by_number(i+1).profile, '3 @ 1, 2 & 3 not ring profile i = ' + i.to_s
    end
  end
  test 'user method which_profile' do
    user = skeleton1
    user.save
    frnd = skeleton2
    frnd.save
    assert user.rings.count == 3
    frndshp = build_skeleton_mutual_friendship(user.username, frnd.username, 3)
    frndshp.each {|f| f.save}
    
    #Test with only a public profile, one profile in the second then in the third ring, and then one in every profile 
    # for when the friendship is in ring 1, 2, & 3
    
    user.rings.each do |ring|
      user.mutual_friendships.first.update_attribute(:ring_id, ring.id)
      assert user.which_profile(frnd) == user.public_ring.profile, '1 profile not public, ring.number = ' + ring.number.to_s
    end

    new_profile = user.rings.find_by_number(2).create_profile
    user.rings.each do |ring|
      user.mutual_friendships.first.update_attribute(:ring_id, ring.id)
      if ring.number <= 2
        assert user.which_profile(frnd) == user.rings.find_by_number(2).profile, '2nd profile in 2 not ring 2, ring.number = ' + ring.number.to_s
      else
        assert user.which_profile(frnd) == user.public_ring.profile, '2nd profile in 2 not public, ring.number = ' + ring.number.to_s
      end
    end    
   
    new_profile.update_attribute(:ring_id, user.rings.find_by_number(1).id)
    user.rings.each do |ring|
      user.mutual_friendships.first.update_attribute(:ring_id, ring.id)
      if ring.number == 1
        assert user.which_profile(frnd) == user.rings.find_by_number(1).profile, '2nd profile in 1 not ring 1, ring.number ' + ring.number.to_s
      else
        assert user.which_profile(frnd) == user.public_ring.profile, '2nd profile in 1 not public ' + ring.number.to_s
      end
    end
    
    user.rings.find_by_number(2).create_profile
    user.rings.each do |ring|
      user.mutual_friendships.first.update_attribute(:ring_id, ring.id)
      case ring.number
        when 1 then
          assert user.which_profile(frnd) == user.rings.find_by_number(1).profile, '3 profiles not ring 1 ' + ring.number.to_s
        when 2 then
          assert user.which_profile(frnd) == user.rings.find_by_number(2).profile, '3 profiles not ring 2 ' + ring.number.to_s
        when 3 then
          assert user.which_profile(frnd) == user.public_ring.profile, '3 profiles not ring 3 ' + ring.number.to_s
      end
    end
    
  end
end