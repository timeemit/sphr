class CreateConeConnections < ActiveRecord::Migration
  def self.up
    create_table :cone_connections do |t| #Maybe rename cone_friendship
      t.references :cone,       :null => false
      t.references :friendship, :null => false
      t.timestamps              :null => false
    end
  end

  def self.down
    drop_table :cone_connections
  end
end
