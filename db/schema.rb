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

ActiveRecord::Schema.define(version: 2021_05_19_225523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_keys", force: :cascade do |t|
    t.string "label"
    t.string "key"
    t.boolean "suspended"
    t.datetime "last_accessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "countries", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_province_management"
    t.date "last_activity_on"
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.bigint "venue_id"
    t.integer "category", default: 0
    t.string "custom_name"
    t.string "room"
    t.string "description", limit: 600
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
    t.datetime "latest_registration_at"
    t.boolean "disable_notifications", default: false, null: false
    t.integer "registration_mode", default: 0
    t.string "registration_url"
    t.string "language_code", limit: 2
    t.boolean "online", default: false, null: false
    t.string "online_url"
    t.datetime "summary_email_sent_at"
    t.datetime "reminder_email_sent_at"
    t.index ["manager_id"], name: "index_events_on_manager_id"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "local_area_venues", force: :cascade do |t|
    t.bigint "local_area_id"
    t.bigint "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_area_id"], name: "index_local_area_venues_on_local_area_id"
    t.index ["venue_id"], name: "index_local_area_venues_on_venue_id"
  end

  create_table "local_areas", force: :cascade do |t|
    t.string "country_code"
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.float "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province_code", limit: 3
    t.date "last_activity_on"
  end

  create_table "managed_records", force: :cascade do |t|
    t.integer "manager_id"
    t.integer "record_id"
    t.string "record_type"
    t.integer "assigned_by_id"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["record_id", "record_type"], name: "index_managed_records_on_record_id_and_record_type"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "administrator"
    t.integer "managed_countries_counter", default: 0, null: false
    t.integer "managed_localities_counter", default: 0, null: false
    t.datetime "summary_email_sent_at"
    t.index ["email"], name: "index_managers_on_email", unique: true
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

  create_table "pictures", force: :cascade do |t|
    t.string "parent_type"
    t.bigint "parent_id"
    t.jsonb "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_type", "parent_id"], name: "index_pictures_on_parent_type_and_parent_id"
  end

  create_table "provinces", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province_code", limit: 3
    t.date "last_activity_on"
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name"
    t.string "email"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "starting_at"
    t.index ["event_id"], name: "index_registrations_on_event_id"
  end

  create_table "stashes", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key"], name: "index_stashes_on_key", unique: true
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
    t.string "province_code", limit: 3
    t.boolean "published", default: true
    t.string "place_id"
    t.date "last_activity_on"
  end

end
