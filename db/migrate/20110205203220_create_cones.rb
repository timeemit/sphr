class CreateCones < ActiveRecord::Migration
  def self.up
    create_table :cones do |t|
      t.references :user, :null => false
      t.string :name,     :null => false
      t.timestamps        :null => false
    end
  end

  def self.down
    drop_table :cones
  end
end
