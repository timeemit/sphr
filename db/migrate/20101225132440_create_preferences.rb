class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.references :user,   :null => :false
      # t.integer   :rings,   :default => 3  # The number of rings that the user may put his friends in
      t.timestamps          :null => false
    end    
  end

  def self.down
    drop_table :preferences
  end
end
