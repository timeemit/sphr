class CreateVibrations < ActiveRecord::Migration
  def self.up
    create_table :vibrations do |t|
      t.references :parent, :null => false
      t.references :child, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :vibrations
  end
end
