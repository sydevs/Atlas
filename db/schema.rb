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

ActiveRecord::Schema.define(version: 2022_08_15_180055) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "area_venues", force: :cascade do |t|
    t.bigint "area_id"
    t.bigint "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_area_venues_on_area_id"
    t.index ["venue_id"], name: "index_area_venues_on_venue_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "country_code"
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.float "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province_code", limit: 3
    t.date "last_activity_on"
    t.datetime "summary_email_sent_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "summary_metadata", default: "{}"
    t.string "time_zone"
    t.bigint "region_id"
    t.index ["region_id"], name: "index_areas_on_region_id"
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

  create_table "clients", force: :cascade do |t|
    t.string "label", null: false
    t.jsonb "config", default: "{}", null: false
    t.string "domain"
    t.bigint "manager_id", null: false
    t.string "public_key", null: false
    t.string "secret_key", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_accessed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_id"
    t.string "external_token"
    t.integer "client_type", default: 0, null: false
    t.index ["external_id"], name: "index_clients_on_external_id", unique: true
    t.index ["manager_id"], name: "index_clients_on_manager_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_regions"
    t.date "last_activity_on"
    t.datetime "summary_email_sent_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "summary_metadata", default: "{}"
    t.string "default_language_code", limit: 2
    t.string "name"
    t.boolean "enable_custom_regions", default: false
    t.jsonb "geojson"
    t.integer "osm_id"
    t.json "translations"
    t.string "bounds", default: [], array: true
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
  end

  create_table "events", force: :cascade do |t|
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
    t.integer "registration_mode", default: 0
    t.string "registration_url"
    t.string "language_code", limit: 2
    t.string "online_url"
    t.datetime "status_email_sent_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "reminder_email_sent_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "should_update_status_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "verified_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "expired_at"
    t.datetime "archived_at"
    t.datetime "finished_at"
    t.integer "status", default: 0, null: false
    t.string "phone_name"
    t.string "phone_number"
    t.integer "registration_type", default: 0, null: false
    t.integer "registration_limit"
    t.string "type"
    t.bigint "venue_id"
    t.bigint "area_id"
    t.index ["area_id"], name: "index_events_on_area_id"
    t.index ["manager_id"], name: "index_events_on_manager_id"
    t.index ["status"], name: "index_events_on_status"
    t.index ["venue_id"], name: "index_events_on_venue_id"
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
    t.string "language_code", limit: 2
    t.datetime "last_login_at"
    t.boolean "email_verified"
    t.datetime "email_verification_sent_at"
    t.integer "contact_method", default: 0, null: false
    t.string "phone"
    t.boolean "phone_verified", default: false
    t.datetime "phone_verification_sent_at"
    t.json "contact_settings", default: {}
    t.integer "notifications", default: 2147483647, null: false
    t.index ["email"], name: "index_managers_on_email", unique: true
    t.index ["phone"], name: "index_managers_on_phone", unique: true
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

  create_table "regions", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "province_code", limit: 3
    t.date "last_activity_on"
    t.datetime "summary_email_sent_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "summary_metadata", default: "{}"
    t.jsonb "geojson"
    t.string "name"
    t.integer "osm_id"
    t.json "translations"
    t.jsonb "bounds"
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name"
    t.string "email"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "starting_at"
    t.string "time_zone"
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
    t.string "time_zone"
    t.string "address", null: false
    t.index ["place_id"], name: "index_venues_on_place_id", unique: true
  end

end
