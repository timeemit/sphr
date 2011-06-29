class CreateRings < ActiveRecord::Migration
  def self.up
    create_table :rings do |t|
      t.references :user,       :null => false
      t.string :name,           :null => false
      t.string :projected_name, :null => false
      t.integer :number,        :null => false
      t.boolean :public_ring,   :null => false #enables the user to declare the name of his/her public ring without compromising its function.
      t.timestamps              :null => false
    end
  end

  def self.down
    drop_table :rings
  end
end
