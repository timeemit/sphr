# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#Users

def create_skeleton_users(number, username, password, characteristic, email_address, email_server)
  number.times do |index|
    User.create(
      :username => username + index.to_s,
      :password => password,
      :password_confirmation => password,
      :email => email_address + index.to_s + '@' + email_server,
      :email_confirmation => email_address + index.to_s + '@' + email_server,
      :distinction => "I am so " + characteristic + index.to_s)
  end
end
def create_skeleton_friendship(user1, user2, ring)
  User.find_by_username(user2).inverse_friendships.create(
    :ring_id => User.find_by_username(user1).rings.find_by_number(ring).id,
    :message => "Hey #{User.find_by_username(user2).username}!", 
    :note => "From #{User.find_by_username(user1).username}!")

  # User.find_by_username(user1).rings.find_by_number(ring).friendships.create(
  #   :friend_id => User.find_by_username(user2).id, 
  #   :message => "Hey #{User.find_by_username(user2).username}!", 
  #   :note => "From #{User.find_by_username(user1).username}!")
end
def create_mutual_friendships(user1, user2, ring)
  create_skeleton_friendship(user1, user2, ring)
  create_skeleton_friendship(user2, user1, ring)
end

User.create(
  :username => 'Oricksum',
  :email => 'LiamNorris1231853211@gmail.com',
  :email_confirmation => 'LiamNorris1231853211@gmail.com',
  :distinction => 'Creator of FrndSphr',
  :password => 'cul1swuB',
  :password_confirmation => 'cul1swuB')

User.create(
  :id => 2,
  :username => 'Redpotion88',
  :email => 'redpotion88@aol.com',
  :email_confirmation => 'redpotion88@aol.com',
  :distinction => 'Fire Crotch!',
  :password => 'Rockstar8',
  :password_confirmation => 'Rockstar8')

User.create(
  :id => 3,
  :username => 'demonPants',
  :email => 'eli_delventhal@redlands.edu',
  :email_confirmation => 'eli_delventhal@redlands.edu',
  :distinction => 'Developer Extraordinnaire',
  :password => 'Megan1',
  :password_confirmation => 'Megan1')

User.create(
  :id => 4,
  :username => '0FatherOfTime1',
  :email => 'will@infobank.com',
  :email_confirmation => 'will@infobank.com',
  :distinction => 'Father of the Creator',
  :password => 'Liam1',
  :password_confirmation => 'Liam1')

#The Friends are intended to be mutual friends of Oricksum for testing.
create_skeleton_users(3, 'Friend', '2Cool4Facebook', 'friendly! ', 'friendly', 'cool.com')
#The Strangers are each friends of Friend1, Friend2, and Friend3 of various degrees for testing Friends of Friends.
create_skeleton_users(3, 'Stranger', '2Different', 'mysterious! ', 'strange', 'different.com')
#The Clingies are users that send invitations that are not responded to
create_skeleton_users(2, 'Clingy', '2Clingy', 'aggressive with my affection ', '2much', '2handle.com')

#The Drones are to make sure that lists of users don't get too crazy.
create_skeleton_users(100, 'Drone', 'TheEnd1sNear', 'unstoppable ', 'coming', '4u.com')

#Friendships

#Oricksum and Redpotion88 are mutual friends, putting each other at Ring 1
User.find_by_username('Redpotion88').inverse_friendships.create(
  :ring_id => User.find_by_username('Oricksum').rings.find_by_number(1).id,
  :message => 'I love you!  Will you be with me forever?',
  :note => 'This is the love of my life!  I never want to lose her.')

User.find_by_username('Oricksum').inverse_friendships.create(
  :ring_id => User.find_by_username('Redpotion88').rings.find_by_number(1).id,
  :message => 'Even though we apart we can still be together on FrndSphr.',
  :note => 'I hope that he comes back')

#Oricksum puts 0FatherOfTime1 in Ring 2
User.find_by_username('0FatherOfTime1').inverse_friendships.create(
  :ring_id => User.find_by_username('Oricksum').rings.find_by_number(2).id,
  :message => 'Hey Dad!',
  :note => 'My Dad')

#demonPants has invited Oricksum to be a friend in Ring 3
User.find_by_username('Oricksum').inverse_friendships.create(
  :ring_id => User.find_by_username('demonPants').rings.find_by_number(3).id,
  :message => 'Hey Liam!  Stay in touch, buddy!',
  :note => 'Liam Norris.  Redlands 2010.  Orgy!')

#demonPants and Redpotion88 are mutual friends putting each other in Ring 2
#This means that Redpotion88 is a mutual friend of demonPants and Oricksum.
#However, Oricksum should be able to see that
# Redpotion 88 is a mutual friend to demonPants but not vice versa.
create_mutual_friendships('Redpotion88', 'demonPants', 2)

#The Friends are mutual friends with Oricksum
3.times{|i| create_mutual_friendships('Oricksum', 'Friend' + i.to_s, 2)}

#The Strangers are friends of Oricksum's friends, The Friends.
#Each of The Friends put The Strangers in their most distant rings.

#Stranger1 has a mutual friendship with Friend1
create_mutual_friendships('Stranger0', 'Friend1', 3)

#Stranger2 has mutual friendships with Friend1, Friend2, and Friend3
3.times{|i| create_mutual_friendships('Stranger1', 'Friend' + i.to_s, 3)}

#Stranger3 is friends with Friend1 and Friend2
2.times{|i| create_mutual_friendships('Stranger2', 'Friend' + i.to_s, 3)}

#Clingy1 and Clingy 2 have both sent invitations to Oricksum
2.times{|i| create_skeleton_friendship('Clingy' + i.to_s, 'Oricksum', 2)}

#Profiles

#Oricksum's private ring profile
User.find_by_username('Oricksum').rings.find_by_number(1).create_profile(
  :first_name => 'Liam',
  :last_name => 'Norris',
  :sex => 'Male')

#Redpotion88's private ring profile
User.find_by_username('Redpotion88').rings.find_by_number(1).create_profile(
  :first_name => 'Shannon',
  :last_name => 'Unser',
  :sex => 'Female')

#demonPants' private ring profile
User.find_by_username('demonPants').rings.find_by_number(1).create_profile(
  :first_name => 'Eli',
  :last_name => 'Delventhal',
  :sex => 'Male')

#0FatherOfTime1's private ring profile
User.find_by_username('0FatherOfTime1').rings.find_by_number(1).create_profile(
  :first_name => 'Will',
  :last_name => 'Norris',
  :sex => 'Male')
