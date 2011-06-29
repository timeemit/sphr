class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      # t.references :user,   :null => false
      t.references :entity, :polymorphic => true, :null => false    #Links to the object enacted upon
      t.references :ring,   :null => false                          #Don't really need this because every entity that an activity looks at has a ring.  But it is probably more efficient.
      t.string :action,     :null => false                          #Describes the action
      t.timestamps          :null => false
    end
  end

  def self.down
    drop_table :activities
  end
end
