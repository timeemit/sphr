require 'test_helper'
require 'generators'
class ConeConnectionTest < ActiveSupport::TestCase
  test 'validates against blank values' do 
    users = build_skeletons(2, 'user')
    users.each{|u| assert u.save, 'user did not save'}
    user = users.first.reload
    friendship = build_skeleton_friendship(user.username, users.last.username, rand(user.rings.count)+1)
    assert friendship.save, 'friendship did not save'
    cone = user.cones.build(:name => 'test')
    assert cone.save, 'cone didn\'t save: '  + cone.errors.full_messages.inspect
    
    #Nine scenarios:  
    # 1.  Cone Connection with blank :user_id, blank :friendship_id, and both attributes blank
    # 2.  Cone accepts attributes for Cone Connection with blank :cone_id, blank :friendship_id, and both attributes blank
    # 3.  Friendship accepts attributes for Cone Connection with blank :cone_id, blank :friendship_id, and both attributes blank
    
    assert cone.cone_connections.empty?, 'ring cc not empty before 1'
  
    #Scenario 1
    assert !ConeConnection.new.save, 'cc blank'
    assert !ConeConnection.new(:friendship_id => friendship.id).save, 'cc cone'
    assert !ConeConnection.new(:cone_id => cone.id).save, 'cc friendship'
    
    cone.cone_connections.each{|cc| cc.destroy}
    assert cone.cone_connections.empty?, 'ring cc not empty before 2'
    
    #Scenario 2
    assert cone.update_attributes(:cone_connections_attributes => [{}]), 'ring blank: ' + cone.errors.full_messages.inspect
    assert cone.cone_connections.empty?, 'ring cc not empty in 2 blank'
    assert cone.update_attributes(:cone_connections_attributes => [{:friendship_id => friendship.id}]), 'ring cone'
    assert cone.cone_connections.empty?, 'ring cc not empty in 2 cone'
    assert cone.update_attributes(:cone_connections_attributes => [{:cone_id => cone.id}]), 'ring friendship'
    assert cone.cone_connections.empty?, 'ring cc not empty in 2 friendship'
    
    #Scenario 3
    assert friendship.update_attributes(:cone_connections_attributes => [{}]), 'friendship blank'
    assert friendship.cone_connections.empty?, 'friendship cc not empty in 3 blank'
    assert friendship.update_attributes(:cone_connections_attributes => [{:friendship_id => friendship.id}]), 'friendship cone'
    assert friendship.cone_connections.empty?, 'friendship cc not empty in 3 cone'
    assert friendship.update_attributes(:cone_connections_attributes => [{:cone_id => cone.id}]), 'friendship friendship'
    assert friendship.cone_connections.empty?, 'friendship cc not empty in 3 friendship'    
    
  end
  test 'validates uniqueness' do
    users = build_skeletons(2, 'user')
    users.each{|u| assert u.save, 'user did not save'}
    user = users.first.reload
    friendship = build_skeleton_friendship(user.username, users.last.username, rand(user.rings.count)+1)
    assert friendship.save, 'friendship did not save'
    cone = user.cones.build(:name => 'test')
    assert cone.save, 'cone didn\'t save: '  + cone.errors.full_messages.inspect
    
    count = ConeConnection.all.count
    
    #This is the first cone_connection
    assert ConeConnection.new(:cone_id => cone.id, :friendship_id => friendship.id).save, 'first cone did not save'
    assert !ConeConnection.all.empty?, 'empty'
    assert ConeConnection.all.count == count + 1, 'more than one: ' + ConeConnection.all.inspect
    
    #Check to see if a cone_connection can't be made by itself or by associations
    assert !ConeConnection.new(:cone_id => cone.id, :friendship_id => friendship.id).save, 'second added'
    assert ConeConnection.all.size == count + 1, 'more than one'
    assert cone.update_attributes(:cone_connections_attributes => [{:cone_id => cone.id, :friendship_id => friendship.id}]), 'cone did not update: ' + cone.errors.full_messages.inspect
    assert ConeConnection.all.size == count + 1, 'more than one because of cone'
    assert friendship.update_attributes(:cone_connections_attributes => [{:cone_id => cone.id, :friendship_id => friendship.id}]), 'cone did not update: ' + friendship.errors.full_messages.inspect
    assert ConeConnection.all.size == count + 1, 'more than one because of friendship'
  end

  test 'cone accepts nested attributes for cone connections' do
    user = skeleton1
    user.save
    user2 = skeleton2
    user2.save
    frndshp = build_skeleton_friendship(user.username, user2.username, 3)
    frndshp.save
    cone = user.cones.build(:name => 'test')
    assert cone.save, 'cone did not save'
    assert cone.update_attributes(:cone_connections_attributes => [{:cone_id => cone.reload.id, :friendship_id => frndshp.id}]), 'did not update: ' + cone.errors.full_messages.inspect
    assert !ConeConnection.all.empty?, 'no cone connection created'
    assert !cone.cone_connections.empty?, 'cone has empty cone connections'
    assert !cone.friendships.empty?, 'empty friendships'
    assert cone.friendships.first.user == user, 'wrong user'
    assert cone.friendships.first.friend == user2, 'wrong friend'
    assert !frndshp.cone_connections.empty?, 'frndshp has empty cone connections'
    assert !frndshp.cones.empty?, 'empty cones'
    assert frndshp.cones.first.name == 'test', 'wrong name'
  end
  test 'friendship accepts nested attributes for cone connections' do
    user = skeleton1
    user.save
    user2 = skeleton2
    user2.save
    cone = user.cones.create(:name => 'test')
    frndshp = build_skeleton_friendship(user.username, user2.username, rand(user.rings.count)+1)
    assert frndshp.save
    
    assert frndshp.update_attributes(:cone_connections_attributes => [{:cone_id => cone.id, :friendship_id => frndshp.id}]), 'did not update: ' + frndshp.errors.full_messages.inspect
    assert !frndshp.cone_connections.empty?, 'frndshp has empty cone connections'
    assert !frndshp.cones.empty?, 'empty cones'
    assert frndshp.cones.first.name == 'test', 'wrong name'
    assert !cone.cone_connections.empty?, 'cone has empty cone connections'
    assert !cone.friendships.empty?, 'empty friendships'
    assert cone.friendships.first.user == user, 'wrong user'
    assert cone.friendships.first.friend == user2, 'wrong friend'
  end
end