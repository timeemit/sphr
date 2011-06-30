# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110622035150) do

  create_table "activities", :force => true do |t|
    t.integer  "entity_id",   :null => false
    t.string   "entity_type", :null => false
    t.integer  "ring_id",     :null => false
    t.string   "action",      :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cone_connections", :force => true do |t|
    t.integer  "cone_id",       :null => false
    t.integer  "friendship_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "cones", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "echoes", :force => true do |t|
    t.integer  "shoutout_id", :null => false
    t.integer  "ring_id",     :null => false
    t.boolean  "signalled",   :null => false
    t.integer  "distance",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "ring_id"
    t.integer  "friend_id"
    t.text     "message"
    t.text     "note"
    t.boolean  "mutual",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "light_signals", :force => true do |t|
    t.integer  "shoutout_id", :null => false
    t.integer  "ring_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permitted_cones", :force => true do |t|
    t.integer  "cone_id",     :null => false
    t.integer  "entity_id",   :null => false
    t.string   "entity_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "profiles", :force => true do |t|
    t.integer  "ring_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "sex"
    t.date     "birthdate"
    t.string   "hometown"
    t.string   "current_location"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "rings", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.string   "name",           :null => false
    t.string   "projected_name", :null => false
    t.integer  "number",         :null => false
    t.boolean  "public_ring",    :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "shoutouts", :force => true do |t|
    t.integer  "ring_id",    :null => false
    t.integer  "author_id",  :null => false
    t.text     "content",    :null => false
    t.integer  "echo_range", :null => false
    t.integer  "echo_count", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                                  :null => false
    t.string   "distinction"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                      :null => false
    t.string   "single_access_token",                    :null => false
    t.string   "perishable_token",                       :null => false
    t.boolean  "activated",           :default => false, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

  create_table "vibrations", :force => true do |t|
    t.integer  "parent_id",  :null => false
    t.integer  "child_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
