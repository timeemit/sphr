class CreateShoutouts < ActiveRecord::Migration
  def self.up
    create_table :shoutouts do |t|
      t.references :ring, :null => false
      t.references :author, :null => false
      t.text :content, :null => false
      t.integer :echo_range, :null => false
      t.integer :echo_count, :null => false #May not be necessary, since shoutout.echoes.count should yield the same value.
      # t.boolean :response, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :shoutouts
  end
end
