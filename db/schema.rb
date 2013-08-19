# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 4) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "role"
    t.string   "city"
    t.string   "location"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "type"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.integer  "city_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "supporters", :force => true do |t|
    t.string   "uniqnum"
    t.date     "acquired"
    t.integer  "account_id"
    t.string   "dd_city"
    t.string   "dd_location"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "gender"
    t.date     "birthday"
    t.string   "occupation"
    t.string   "city"
    t.string   "street_name"
    t.string   "num_building"
    t.string   "num_apartment"
    t.string   "zip_code"
    t.string   "home_phone",      :limit => 12
    t.string   "mobile_phone",    :limit => 12
    t.string   "email"
    t.boolean  "receive_updates"
    t.integer  "ap_monthly"
    t.integer  "ap_one_off"
    t.text     "notes"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

end
