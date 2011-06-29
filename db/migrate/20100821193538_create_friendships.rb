class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.references :ring,   :null => :false                       #Ring of friendship sets their distance
      t.references :friend, :null => :false
      t.text    :message                                          #This is a message from the user to the friend
      t.text    :note                                             #This is a note about the friend
      # t.integer :weight, :null => :false
      t.boolean :mutual,                      :default => false   #This is true if the friendship is mutual
      t.timestamps          :null => false
    end
  end
  
  def self.down
    drop_table :friendships
  end
end
