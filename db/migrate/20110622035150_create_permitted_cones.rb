class CreatePermittedCones < ActiveRecord::Migration
  def self.up
    create_table :permitted_cones do |t|
      t.references :cone, :null => false
      t.references :entity, :null => false, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :permitted_cones
  end
end
