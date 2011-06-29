class CreateLightSignals < ActiveRecord::Migration
  def self.up
    create_table :light_signals do |t|
      t.references :shoutout, :null => false
      t.references :ring, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :light_signals
  end
end
