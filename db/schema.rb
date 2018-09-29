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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_29_183326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data_encrypting_keys", id: :serial, force: :cascade do |t|
    t.string "encrypted_key"
    t.boolean "primary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_key_iv"
  end

  create_table "encrypted_strings", id: :serial, force: :cascade do |t|
    t.string "encrypted_value"
    t.string "encrypted_value_iv"
    t.integer "data_encrypting_key_id"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_encrypting_key_id"], name: "index_encrypted_strings_on_data_encrypting_key_id"
    t.index ["token"], name: "index_encrypted_strings_on_token"
  end

  add_foreign_key "encrypted_strings", "data_encrypting_keys"
end
