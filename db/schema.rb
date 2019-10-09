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

ActiveRecord::Schema.define(version: 20191008165919) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.string "model_type"
    t.bigint "model_id"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_type", "model_id"], name: "index_authorizations_on_model_type_and_model_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "country_code", null: false
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.bigint "venue_id"
    t.integer "category", default: 0
    t.string "name"
    t.string "room"
    t.string "description"
    t.string "languages", array: true
    t.date "start_date"
    t.date "end_date"
    t.string "start_time"
    t.string "end_time"
    t.integer "recurrence", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "images"
    t.bigint "manager_id"
    t.boolean "published", default: true
    t.index ["languages"], name: "index_events_on_languages", using: :gin
    t.index ["manager_id"], name: "index_events_on_manager_id"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "local_areas", force: :cascade do |t|
    t.string "country_code"
    t.string "name"
    t.string "identifier"
    t.float "latitude"
    t.float "longitude"
    t.float "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province_code", limit: 3
  end

  create_table "managed_records", id: false, force: :cascade do |t|
    t.integer "manager_id"
    t.integer "record_id"
    t.string "record_type"
    t.index ["record_id", "record_type"], name: "index_managed_records_on_record_id_and_record_type"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "administrator"
    t.index ["email"], name: "index_managers_on_email"
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.string "authenticatable_type"
    t.bigint "authenticatable_id"
    t.datetime "timeout_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "claimed_at"
    t.text "user_agent", null: false
    t.string "remote_addr", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
  end

  create_table "provinces", force: :cascade do |t|
    t.string "country_code", null: false
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province_code", limit: 3
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id"
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
    t.string "street"
    t.string "city"
    t.string "country_code"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "manager_id"
    t.string "province_code", limit: 3
    t.boolean "published", default: true
    t.index ["manager_id"], name: "index_venues_on_manager_id"
  end

end
