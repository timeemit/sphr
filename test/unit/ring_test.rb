require 'test_helper'
require 'generators'

class RingTest < ActiveSupport::TestCase
  test 'validates against blank ring' do
    ring = Ring.new
    assert ring.number == nil, 'blank ring has a number'
    assert ring.user_id == nil, 'blank ring has a user_id'
    assert ring.name == nil, 'blank ring has a name'
    assert !ring.save, 'blank ring saved'
  end
  test 'validates uniqueness of number' do
    user = skeleton1
    user.save
    user.rings.count {|i| assert = !user.rings.build(:number => i+1).save, "ring.number = #{ring.number}"}
  end
  test 'validates uniqueness of public ring if true' do
    user = skeleton1
    user.save
    assert !user.public_ring.nil?, 'public ring is still nil after save'
    new_ring = user.rings.build
    new_ring.number = user.public_ring.number + 1
    new_ring.public_ring = true
    assert !new_ring.save, 'second public ring saved'
  end
  test 'validates numericality of number' do
    user = skeleton1
    user.save
    
    #No ring with number zero
    assert !user.rings.build(:number => 0).save, '0 ring saved'
    
    #No ring with negative integer
    100.times {assert !user.rings.build(:number => -rand(10)).save, 'negative ring saved'}
      
    #No floating point numbers 
    100.times {assert !user.rings.build(:number => 10*rand).save, 'floating point ring saved'}
  end
  test 'validates against high number' do
    user = skeleton1
    user.save
    100.times{assert !user.rings.build(:number => user.rings.count + 1 + rand(10)).save}
  end
  test 'validates against really high number' do
    user = skeleton1
    user.save
    100.times{assert !user.rings.find_by_number(rand(user.rings.count)+1).update_attributes(:number => user.rings.count + 2 + rand(10))}
    #Maybe should also test to make sure that number can be changed to user.rings.count + 1
  end
  
  test 'assocation to user cannot be altered' do
    user = skeleton1
    assert user.save, 'skeleton1 could not save'
    user.rings.each do |ring|
      assert ring.number.integer?, 'ring doesn\'t have a number'
      assert ring.user_id.integer?, 'ring isn\'t associated to a user'
      ring.update_attributes(:user_id => nil)
      assert ring.user_id != nil, 'ring user_id is nil after update'
    end
  end
  test 'association of user to public ring' do
    user = skeleton1
    assert user.public_ring.nil?, 'public ring is not nil before save'
    user.save
    assert !user.public_ring(true).nil?, 'public ring is still nil after save'
    assert user.rings.count == user.public_ring.number, 'public ring is not the right number'
  end
  test 'association to user rings' do
    user = skeleton1
    user.save
    user.rings.each do |ring|
      assert_equal ring.user_rings, user.rings
    end
  end
  test 'association to this and farther rings as well as this and closer rings' do
    user = skeleton1
    user.save
    user.rings.order('number DESC').each do |ring|
      assert_equal ring.this_and_farther_rings, user.rings.where('number >= ?', ring.number), "number = #{ring.number}"
      assert_equal ring.this_and_closer_rings, user.rings.where('number <= ?', ring.number), "number = #{ring.number}"
    end
  end
  
  test 'deletion of public ring impossible' do
    user = skeleton1
    user.save
    assert !user.public_ring.destroy
  end
  test 'deletion of ring causes shift' do
    user = skeleton1
    user.save
    ring_preference = user.rings.count
    assert ring_preference == 3, 'ring_preference != 3'
    (2 * ring_preference**2).times do
      ring_preference.times {|i| assert user.rings(true).exists?(:number => i+1), "missing ring before deletion i = #{i.to_s}"}
      
      missing_ring = rand(ring_preference) + 1
      user.rings(true).find_by_number(missing_ring).destroy
      
      if missing_ring == ring_preference
        (ring_preference).times {|i| assert user.rings(true).exists?(:number => i+1), "missing ring after no deletion i = #{i.to_s} deleted ring = #{missing_ring.to_s}"}
      else
        assert user.rings(true).find_by_public_ring(true).number == ring_preference - 1, "public ring remains unshifted"
        (ring_preference - 1).times {|i| assert user.rings(true).exists?(:number => i+1), "missing ring after deletion i = #{i.to_s} deleted ring = #{missing_ring.to_s}"}
        (ring_preference - 1).times {|i| assert user.rings(true).find_all_by_number(i+1).size == 1, 'more that one ring when i = ' + i.to_s + ' deleted_ring = ' + missing_ring.to_s}
      end
      
      user.destroy
      user = skeleton1
      assert user.save, 'new skeleton1 user did not save'
      ring_preference = user.rings.count
    end
  end
  test 'deletion of ring with associations impossible' do
    users = build_skeletons(2, 'user')
    users.each{|u| u.save}
    ring_preference = users.first.rings.count
    
    (2 *ring_preference *ring_preference).times do
      random_ring = rand(ring_preference) +1
      build_skeleton_friendship(users.first.username, users.last.username, random_ring).save
      assert !users.first.rings.find_by_number(random_ring).friendships.empty?, 'no friendships in ring'
      users.first.rings.find_by_number(random_ring).destroy
      assert users.first.rings(true).exists?(:number => random_ring), 'deleted ring with friendship'

      build_skeleton_friendship(users.last.username, users.first.username, random_ring).save
      assert !users.first.rings.find_by_number(random_ring).mutual_friendships.empty?, 'no mutual friendships in ring'
      users.first.rings.find_by_number(random_ring).destroy
      assert users.first.rings(true).exists?(:number => random_ring), 'deleted ring with mutual friendship'
      
      unless random_ring == ring_preference
        assert users.first.rings.find_by_number(random_ring).public_ring == false, 'ring is public'
        users.first.rings.find_by_number(random_ring).create_profile        
        assert !users.first.rings.find_by_number(random_ring).profile.nil?, 'no profile in ring'
        users.first.rings.find_by_number(random_ring).destroy
        assert users.first.rings(true).exists?(:number => random_ring), 'deleted ring with profile'
      end
   
      #Create a fresh batch of users for another random ring
      users.each{|user| user.destroy}
      users = build_skeletons(2, 'user')
      users.each{|u| u.save}
      ring_preference = users.first.rings.count
    end
  end
  
  test 'continuity' do
    user = skeleton1
    user.save
    random_number = rand(user.rings.count)+1
    user.rings.create(:number => random_number, :name => 'Random')
    user.rings(true).count.times do |i|
      if i+1 > random_number
        assert user.rings.exists?(:number => i+1), 'number should have shifted, i = ' + i.to_s + ' random_number = ' + random_number.to_s
      elsif i+1 == random_number
        assert user.rings.exists?(:number => i+1), 'new ring was not created, i = ' + i.to_s + ' random_number = ' + random_number.to_s
        assert user.rings.find_by_number(i+1).name == 'Random', 'Name of new random ring was not "Random", i = ' + i.to_s + ' random_number = ' + random_number.to_s
      else
        assert user.rings.exists?(:number => i+1), 'number should not have shifted, i = ' + i.to_s + ' random_number = ' + random_number.to_s
      end
    end
  end
  test 'projected name' do
    user = skeleton1
    user.save
    user.rings.each {|ring| assert ring.projected_name == user.username}
  end
  
  test 'color' do
    user = saved_skeleton1
    (user.rings.count-1).times do
      user.rings.find_by_number(1).destroy
    end
    
    5.times do |i|
      count = user.rings(true).count
      assert count == i+1, "i is #{i.to_s} but is not count, which is #{count.to_s}"
      user.rings.each do |ring|
        assert ring.color[:green] == 0, "#{count.to_s} rings green wrong"
        if ring.number == 1
          assert ring.color[:red] == 0, "#{count.to_s} rings number #{ring.number}  red wrong is #{ring.color[:red]} not 0"
          assert ring.color[:blue] == 255, "#{count.to_s} rings number #{ring.number}  blue wrong is #{ring.color[:red]} not 255"
        elsif ring.number == count
          assert ring.color[:red] == 255, "#{count.to_s} rings number #{ring.number}  red wrong is #{ring.color[:red]} not 255"
          assert ring.color[:blue] == 0, "#{count.to_s} rings number #{ring.number}  red wrong is #{ring.color[:red]} not 0"
        else
          assert ring.color[:red] == 256*(ring.number-1)/(count-1) - 1, "#{count.to_s} rings number #{ring.number}  red wrong is #{ring.color[:red]}"
          assert ring.color[:blue] == 256*((count-1)-ring.number+1)/(count-1) - 1, "#{count.to_s} rings number #{ring.number} blue wrong is #{ring.color[:blue]}"
        end
      end
      assert user.rings.build(:number => 1, :name => "Test#{(i+1).to_s}").save, "Test#{(i+1).to_s} no save"
    end
    
  end
  
  test 'user method which_ring' do
    users = build_skeletons(2, 'bonebag')
    users.each{|user| user.save}
    assert users.each{|user| user.which_ring(user) == user.rings.find_by_number(1)}, 'not nil when passed self'
    build_skeleton_mutual_friendship(users.first.username, users.last.username, 1).each{|f| f.save}
    users.first.rings.count.times do |a|
      assert users.first.mutual_friendships.first.update_attributes(:ring_id => users.first.rings.find_by_number(a + 1).id), 'first friendship failed to update'
      users.last.rings.count.times do |b|
        assert users.last.mutual_friendships.first.update_attributes(:ring_id => users.last.rings.find_by_number(a + 1).id), 'last friendship failed to update'
        assert users.first.which_ring(users.last).number == a + 1, 'first friendship isn\'t correct' 
        assert users.last.which_ring(users.first).number == a + 1, 'friendship isn\'t correct'
      end        
    end
  end
  test 'user method ring array' do
    #Tests User.ring_array method.
    #First makes sure that the initial ring array with rings.count = 3 creates the array [1, 2, 3] 
    user = skeleton1
    user.save
    assert_equal user.ring_array, [1, 2, 3], 'Initial ring array was not [1, 2, 3]'
    #Then assigns a random number ranging from 1 and 10 to rings.count and asserts that the proper ring array was created.
    100.times do |a|
      #Randomly either insert or destroy a non-public ring, then assert that the ring_array is correct.
      add_or_remove = rand(2)
      if add_or_remove == 1
        (rand(10) + 1).times{|b| assert user.rings.build(:number => rand(user.rings(true).count) + 1, :name => a+b), 'new ring didn\'t save'}
      else
        (rand (user.rings(true).count) ).times {user.rings.find_by_number(rand(user.rings(true).count) + 1).destroy}
      end
      rings = Array.new
      user.rings(true).order('number ASC').select('number').each{|i| rings << i.number}
      assert_equal user.ring_array, rings, "ring_array #{user.ring_array} was not the array #{rings}"
    end
  end
end