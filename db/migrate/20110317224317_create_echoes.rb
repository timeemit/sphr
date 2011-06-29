class CreateEchoes < ActiveRecord::Migration
  def self.up
    create_table :echoes do |t|
      t.references :shoutout, :null => false
      t.references :ring, :null => false #For the recipient's ring
      t.boolean :signalled, :null => false #To distinguish between echoes that were originally signals.
      t.integer :distance, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :echoes
  end
end
