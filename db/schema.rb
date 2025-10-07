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

ActiveRecord::Schema[8.0].define(version: 2025_10_07_195446) do
  create_table "bookings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "slot_id", null: false
    t.datetime "booked_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slot_id"], name: "index_bookings_on_slot_id"
    t.index ["user_id", "slot_id"], name: "index_bookings_on_user_id_and_slot_id", unique: true
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "slots", force: :cascade do |t|
    t.integer "day_of_week", null: false
    t.time "starts_at", null: false
    t.time "ends_at", null: false
    t.integer "max_participants", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day_of_week", "starts_at"], name: "index_slots_on_day_of_week_and_starts_at", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "bookings", "slots"
  add_foreign_key "bookings", "users"
end
