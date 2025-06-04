# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_04_110520) do
  create_table "securial_roles", id: :string, force: :cascade do |t|
    t.string "role_name"
    t.boolean "hide_from_profile", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "securial_users", id: :string, force: :cascade do |t|
    t.string "email_address", null: false
    t.boolean "email_verified", default: false, null: false
    t.string "email_verification_token"
    t.datetime "email_verification_token_created_at"
    t.string "username", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "bio"
    t.string "password_digest"
    t.datetime "password_changed_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_created_at"
    t.boolean "locked", default: false, null: false
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_securial_users_on_email_address", unique: true
    t.index ["username"], name: "index_securial_users_on_username", unique: true
  end
end
