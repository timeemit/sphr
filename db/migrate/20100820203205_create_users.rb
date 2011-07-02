class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :username,            :null => true                 # optional, you can use email instead, or both
      # t.string    :email,               :null => false                # optional, you can use login instead, or both
      t.string    :distinction,         :null => true                 # A note to anyone that might be mystified by a username
      t.boolean   :activated,           :null => false, :default => false
      
      # Devise methods
      t.database_authenticatable :null => false
      # t.recoverable
      # t.rememberable
      # t.trackable
      # t.encryptable
      t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable

      t.timestamps                      :null => false


      # Authlogic columns
      # t.string    :crypted_password,    :null => true                 # optional, see below
      # t.string    :password_salt,       :null => true                 # optional, but highly recommended
      # t.string    :persistence_token,   :null => false                # required
      # t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      # t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      # t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      # t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      # t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
      # t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
      # t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
      # t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
      # t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns
    end
    # More Deivse methods
    add_index :users, :email,                :unique => true
    # add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true 
  end

  def self.down
    drop_table :users
  end
end
