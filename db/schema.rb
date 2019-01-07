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

ActiveRecord::Schema.define(version: 20181123150416) do

  create_table "authorizations", force: :cascade do |t|
    t.string "model_type"
    t.integer "model_id"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_type", "model_id"], name: "index_authorizations_on_model_type_and_model_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "venue_id"
    t.integer "category", default: 0
    t.string "name"
    t.string "room"
    t.string "contact_email"
    t.string "description"
    t.date "start_date"
    t.date "end_date"
    t.string "start_time"
    t.string "end_time"
    t.integer "recurrence", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.string "email"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_registrations_on_event_id"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.string "contact_email"
    t.string "address_street"
    t.string "address_room"
    t.string "address_municipality"
    t.string "address_subnational"
    t.string "address_country"
    t.string "address_postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
