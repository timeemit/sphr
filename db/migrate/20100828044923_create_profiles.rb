class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      # t.references :user,   :null => :false
      t.references :ring,      :null => :false
      # t.string :projected_name
      t.string :first_name
      t.string :last_name
      t.string :sex
      t.date :birthdate
      t.string :hometown
      t.string :current_location
      t.timestamps              :null => false
    end
    
  end
  
  def self.down
    drop_table :profiles
  end
end
