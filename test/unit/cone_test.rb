require 'test_helper'
require 'generators'

#MUST successfully write attr_accessible for cone_connection association
class ConeTest < ActiveSupport::TestCase
  test 'blank cone' do 
    assert !Cone.new.save
  end
  test 'validates presence of name' do
    user = skeleton1
    user.save
    assert !user.cones.build(:name => nil).save
  end
  #Write this test!
  test 'validates format of name' do
    
  end

  test 'association to cone_connections' do
    assert Cone.create.cone_connections.empty?
  end
  test 'association to friendships' do
    assert Cone.create.friendships.empty?
  end
  
end