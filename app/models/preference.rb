#Probably a necessary model but it is NOT currently used effectively.
#MUST phase out the user.preference.rings command and just call user.rings.count
#This should contain the user's preferred language

class Preference < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
end
