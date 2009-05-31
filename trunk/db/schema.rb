# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090504083903) do

  create_table "configurations", :force => true do |t|
    t.string "config_key",   :limit => 20, :default => "", :null => false
    t.string "config_value",               :default => "", :null => false
  end

  add_index "configurations", ["config_key"], :name => "index_configurations_on_config_key", :unique => true

  create_table "dayusages", :force => true do |t|
    t.integer  "slice_id",               :default => 0,                     :null => false
    t.integer  "node_id",                :default => 0,                     :null => false
    t.date     "day",                                                       :null => false
    t.integer  "total_activity_minutes", :default => 0,                     :null => false
    t.float    "avg_cpu",                :default => 0.0,                   :null => false
    t.float    "avg_send_BW",            :default => 0.0,                   :null => false
    t.float    "avg_recv_BW",            :default => 0.0,                   :null => false
    t.float    "total_cpu",              :default => 0.0,                   :null => false
    t.float    "total_send_BW",          :default => 0.0,                   :null => false
    t.float    "total_recv_BW",          :default => 0.0,                   :null => false
    t.float    "max_cpu",                :default => 0.0,                   :null => false
    t.float    "max_send_BW",            :default => 0.0,                   :null => false
    t.float    "max_recv_BW",            :default => 0.0,                   :null => false
    t.integer  "number_of_samples",      :default => 0,                     :null => false
    t.datetime "last_update",            :default => '2009-01-01 00:00:00', :null => false
  end

  add_index "dayusages", ["last_update"], :name => "index_dayusages_on_last_update"

  create_table "nodes", :force => true do |t|
    t.string  "hostname",         :limit => 100, :default => "",   :null => false
    t.string  "primaryipaddress", :limit => 100, :default => "",   :null => false
    t.boolean "online",                          :default => true
  end

  add_index "nodes", ["hostname", "primaryipaddress"], :name => "hostname", :unique => true

  create_table "samples", :force => true do |t|
    t.integer  "slice_id",       :default => 0,   :null => false
    t.integer  "node_id",        :default => 0,   :null => false
    t.datetime "dayAndTime",                      :null => false
    t.float    "cpu",            :default => 0.0, :null => false
    t.float    "avgSendBW",      :default => 0.0, :null => false
    t.float    "avgRecvBW",      :default => 0.0, :null => false
    t.integer  "sampleInterval", :default => 0,   :null => false
  end

  create_table "slicegroups", :force => true do |t|
    t.string "name",        :limit => 100, :default => "", :null => false
    t.string "description",                :default => "", :null => false
  end

  add_index "slicegroups", ["name"], :name => "index_slicegroups_on_name", :unique => true

  create_table "slices", :force => true do |t|
    t.string  "name",          :default => "", :null => false
    t.integer "slicegroup_id", :default => 3,  :null => false
  end

  add_index "slices", ["name"], :name => "index_slices_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string "login",    :limit => 80
    t.string "password", :limit => 40
  end

end
