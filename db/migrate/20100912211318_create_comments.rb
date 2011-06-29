#Maybe create a shoutback, which would essentially be comments?

class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id
      t.integer :post_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end