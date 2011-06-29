class Activity < ActiveRecord::Base
  # belongs_to :user      #Allows database retrieval of all of a user's activities in chronological order without applying a sort function
  belongs_to :entity, :polymorphic => :true
  belongs_to :ring      #Allows filtering of activities by ring.  Better to use in conjuction with belongs_to :user than to go through :ring.

  validates_presence_of :ring_id, :entity_id, :entity_type, :action#, :user_id
end