require 'test_helper'
require 'generators'

# 1 errors as of June 29th, 2011    
#   test_validates_presence_of_password(UserTest) [unit/user_test.rb:23]:
# empty password saved

class UserTest < ActiveSupport::TestCase
  test 'create user with only email address' do
    user = User.new(:email => 'a1@b.com', :email_confirmation => 'a1@b.com')
    assert user.save, "error messages: #{user.errors.full_messages}"
  end
  test 'skeletons 1 & 2 validity' do
    assert skeleton1.save, "skeleton1 was unable to save, errors: #{skeleton1.errors.full_messages}"
    assert skeleton2.save, 'skeleton2 was unable to save'
  end
  test 'skeleton build' do
    #Creates a random number (10) of 'skelly' users 1 time.
    #Checks the attributes of each skelly, making sure they have rings and no friendships
    1.times do |j|
      number = 10
      name = String.new('skelly')  #It would be better if this were a string of random length and value.
      skellies = build_skeletons(number, j.to_s + name)
      assert !skellies.empty?, 'empty skellies array'
      assert !skellies.include?(nil), 'nil object created in skellies array'
      skellies.each.with_index do |skeleton, i| 
        assert skeleton.username == j.to_s + name + i.to_s, "#{skeleton.username} has an incorrect username."
        assert skeleton.password == 'Sk3lly', "#{skeleton.username} has an incorrect password: #{skeleton.password}" #will probably fail because of the encryption
        assert skeleton.email == skeleton.username + '@frndsphr.com', "#{skeleton.username} has an incorrect email #{skeleton.email}"
        assert skeleton.distinction == 'I am ' + skeleton.username, "#{skeleton.username} has an incorrect distinction #{skeleton.distinction}"
        assert skeleton.save, "#{skeleton.username} did not save.  Errors: #{skeleton.errors.full_messages}"
        assert skeleton.rings.count == 3, "#{skeleton.username} does not have three rings (#{skeleton.rings.count})"
        skeleton.rings.count.times{|i| assert skeleton.rings.exists?(:number => i+1), "#{skeleton.username} does not have ring #{i+1}"}
        assert skeleton.friendships.empty?, "#{skeleton.username} has a nonempty set of friendships"
        skeleton = nil
      end
      skellies = nil
    end
  end
  
  test 'validates against blank user' do 
    assert !User.new.save, 'Blank User Created'
  end  
  test 'validates presence of username' do
    user = skeleton1
    user.username = ''
    assert !user.save, 'empty username saved'
    user.username = 'nil'
    assert !user.save, 'nil username saved'
  end
  test 'validates presence of password' do
    # Password refuses to be assigned an empty string or nil value for some reason.
    user = skeleton1
    user.password = ''
    assert user.password == '', "password is stil #{user.password}"
    assert !user.save, "empty password saved, errors: #{user.errors.full_messages}"
    user.password = nil
    assert user.password == nil, "password is stil #{user.password}"
    assert !user.save, 'nil password saved'
  end
  test 'validates presence of password confirmation' do
    user = skeleton1
    user.password_confirmation = ''
    assert !user.save, 'empty password confirmation saved'
    user.password_confirmation = nil
    assert !user.save, 'nil password confirmation saved'
  end
  test 'validates presence of email' do
    user = skeleton1
    user.email = ''
    assert !user.save, 'empty email saved'
    user.email = nil
    assert !user.save, 'nil email saved'
  end
  test 'validates presence of email confirmation' do  
    user = skeleton1
    user.email_confirmation = ''
    assert !user.save, 'empty email confrmation saved'
    user.email_confirmation = nil
    assert !user.save, 'nil email confirmation saved'
  end
  test 'validates uniqueness of username' do
    user1 = skeleton1
    user2 = skeleton2
    user1.username = user2.username
    user1.save
    assert !user2.save
  end
  test 'validates uniqueness of email' do
    user1 = skeleton1
    user2 = skeleton2
    user2.email = user1.email
    user2.email_confirmation = user1.email_confirmation
    assert user1.email == user2.email, 'emails are not equal'
    assert user1.email_confirmation == user2.email_confirmation, 'email confirmations are not equal'
    assert user1.email == user1.email_confirmation, 'user1 email and email confirmation are not equal'
    assert user1.save, 'user1 did not save'
    assert !user2.save, 'user2 saved'
  end
  test 'validates confirmation of password' do
    user = skeleton1
    user.password_confirmation << ' '
    assert !user.save
  end
  test 'validates confirmation of email' do
    user = skeleton1
    user.email_confirmation << ' '
    assert !user.save
  end
  test 'validates minimum length of username' do
    user = skeleton1
    
    user.username = '123'
    assert !user.save, 'username with 3 characters saved'
    
    user.username = '1234'
    assert user.save, 'username with 4 characters did not save'
  end
  test 'validates maximum length of username' do
    user = skeleton1
    
    user.username = '1234567890ABCDEFGHIJK'
    assert !user.save, 'username with 21 characters saved'
    
    user.username = '1234567890ABCDEFGHIJ'
    assert user.save, 'username with 20 characters did not save'
  end
  test 'validates minimum length of password' do
    user = skeleton1
    
    user.password = 'Ab34'
    user.password_confirmation = 'Ab34'
    assert !user.save, 'password with 4 characters saved'
    
    # user.password = 'Ab3456'
    # user.password_confirmation = 'Ab3456'
    # assert user.save, "password with 6 characters did not save: #{user.errors.full_messages}"
    # 
    user.password = 'Ab345'
    user.password_confirmation = 'Ab345'
    assert user.save, 'password with 5 characters did not save'
  end
  test 'validates maximum length of password' do
    user = skeleton1
    
    user.password = 'ABCDEFGHIJ1234567890abcdefghijk'
    user.password_confirmation = 'ABCDEFGHIJ1234567890abcdefghijk'
    assert !user.save, 'password with 31 characters saved'
        
    user.password = 'ABCDEFGHIJ1234567890abcdefghij'
    user.password_confirmation = 'ABCDEFGHIJ1234567890abcdefghij'
    assert user.password.length == 30, 'ABCDEFGHIJ1234567890abcdefghij is not 30 characters'
    assert user.save, 'password with 30 characters did not save'
  end
  test 'associations before creation are functioning and are all blank' do
    user = skeleton1
    
    assert user.accessed_rings.empty?, 'nonempty accessed rings before save'
    assert user.activities.empty?, 'nonempty activities array before save'
    assert user.cones.empty?, 'nonempty cones array before save'
    assert user.comments.empty?, 'nonempty comments array before save'
    assert user.echoes.empty?, 'nonempty echoes array before save'
    assert user.inverse_friendships.empty?, 'nonempty inverse_friendships array before save'
    assert user.inverse_friends.empty?, 'nonempty inverse_friends array before save'
    assert user.inverse_mutual_friendships.empty?, 'nonempty inverse_mutual_friendships before save'
    assert user.friendships.empty?, 'nonempty friendships array before save'
    assert user.friends.empty?, 'nonempty friends array before save'
    assert user.mutual_friendships.empty?, 'nonempty mutual_friendships array before save'
    assert user.mutual_friends.empty?, 'nonempty mutual_friends array before save'
    assert user.preference.nil?, 'existing preference before save'
    assert user.profiles.empty?, 'nonempty profiles array before save'
    assert user.public_profile.nil?, 'nil public profile array before save'
    assert user.public_ring.nil?, 'existing public ring before save'
    assert user.rings.empty?, 'nonempty ring array before save'
    assert user.shoutouts.empty?, 'nonempty shoutouts array before save'
    
    assert !user.activated, 'user is marked as activated before save'
  end
  test 'creates user with capital email' do
    user = User.new(:email=>'F@1.com', :email_confirmation=>'F@1.com')
    assert user.save, "Errors: #{user.errors.full_messages}"
  end

  #WRTIE THESE TESTS!!!
  test 'validates format of username' do #test UNWRITTEN!
    
  end
  test 'validates format of password' do #test UNWRITTEN!
    
  end
  test 'validates format of email' do #test UNWRITTEN!
    
  end
  test 'valdiates length of distinction' do
  end

  # test 'validates uniqueness of distinction' do
  # Deprecated.
  #   user1 = skeleton1
  #   user2 = skeleton2
  #   user1.distinction = user2.distinction
  #   user1.save
  #   assert !user2.save
  # end
  # test 'validates presence of distinction' do
  # Deprecated
  #   user = skeleton1
  #   user.distinction = ''
  #   assert !user.save, 'empty distinction saved'
  #   user.distinction = nil
  #   assert !user.save, 'nil distinction saved'
  # end

end