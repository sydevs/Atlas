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

ActiveRecord::Schema[7.0].define(version: 2024_07_28_172618) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "area_venues", force: :cascade do |t|
    t.bigint "area_id"
    t.bigint "venue_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["area_id"], name: "index_area_venues_on_area_id"
    t.index ["venue_id"], name: "index_area_venues_on_venue_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "country_code"
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.float "radius"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "last_activity_on"
    t.datetime "summary_email_sent_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "summary_metadata", default: "{}"
    t.string "time_zone"
    t.bigint "region_id"
    t.string "subtitle"
    t.index ["region_id"], name: "index_areas_on_region_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.string "parent_type"
    t.bigint "parent_id"
    t.string "person_type"
    t.bigint "person_id"
    t.bigint "replies_to_id"
    t.bigint "replied_by_id"
    t.bigint "conversation_id"
    t.string "uuid", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_audits_on_category"
    t.index ["conversation_id"], name: "index_audits_on_conversation_id"
    t.index ["parent_type", "parent_id"], name: "index_audits_on_parent"
    t.index ["person_type", "person_id"], name: "index_audits_on_person"
    t.index ["replied_by_id"], name: "index_audits_on_replied_by_id"
    t.index ["replies_to_id"], name: "index_audits_on_replies_to_id"
    t.index ["uuid"], name: "index_audits_on_uuid"
  end

  create_table "clients", force: :cascade do |t|
    t.string "label", null: false
    t.jsonb "config", default: {}, null: false
    t.string "domain"
    t.bigint "manager_id", null: false
    t.string "public_key", null: false
    t.string "secret_key", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "last_accessed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.string "external_token"
    t.integer "client_type", default: 0, null: false
    t.string "location_type"
    t.bigint "location_id"
    t.index ["external_id"], name: "index_clients_on_external_id", unique: true
    t.index ["location_type", "location_id"], name: "index_clients_on_location"
    t.index ["manager_id"], name: "index_clients_on_manager_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "marked_complete_at"
    t.datetime "last_response_at"
    t.string "last_responder_type"
    t.bigint "last_responder_id"
    t.string "parent_type"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_responder_type", "last_responder_id"], name: "index_conversations_on_last_responder"
    t.index ["parent_type", "parent_id"], name: "index_conversations_on_parent"
  end

  create_table "countries", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "enable_regions"
    t.date "last_activity_on"
    t.datetime "summary_email_sent_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "summary_metadata", default: "{}"
    t.string "default_language_code", limit: 2
    t.string "name"
    t.boolean "enable_custom_regions", default: false
    t.jsonb "geojson"
    t.string "osm_id"
    t.json "translations", default: {}, null: false
    t.string "bounds", default: [], array: true
    t.string "canonical_domain"
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.integer "category", default: 0
    t.string "custom_name"
    t.string "room"
    t.string "description", limit: 600
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "images"
    t.bigint "manager_id"
    t.boolean "published", default: true
    t.datetime "latest_registration_at", precision: nil
    t.integer "registration_mode", default: 0
    t.string "registration_url"
    t.string "language_code", limit: 2
    t.string "online_url"
    t.datetime "status_email_sent_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "registrations_email_sent_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "should_update_status_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "verified_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "expired_at", precision: nil
    t.datetime "archived_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.integer "status", default: 0, null: false
    t.string "phone_name"
    t.string "phone_number"
    t.integer "registration_type", default: 0, null: false
    t.integer "registration_limit"
    t.string "type"
    t.bigint "venue_id"
    t.bigint "area_id"
    t.integer "registration_notification", default: 0, null: false
    t.integer "registration_question", default: 1, null: false
    t.jsonb "contact_info", default: {}, null: false
    t.integer "expiration_period", default: 3, null: false
    t.integer "verification_streak", default: 0, null: false
    t.json "recurrence_data", default: {}
    t.date "finish_date"
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
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["record_id", "record_type"], name: "index_managed_records_on_record_id_and_record_type"
  end

  create_table "managers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "administrator"
    t.string "language_code", limit: 2
    t.datetime "last_login_at", precision: nil
    t.boolean "email_verified"
    t.datetime "email_verification_sent_at", precision: nil
    t.integer "contact_method", default: 0, null: false
    t.string "phone"
    t.boolean "phone_verified", default: false
    t.datetime "phone_verification_sent_at", precision: nil
    t.json "contact_settings", default: {}
    t.integer "notifications", default: 2147483647, null: false
    t.index ["email"], name: "index_managers_on_email", unique: true
    t.index ["phone"], name: "index_managers_on_phone", unique: true
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.string "authenticatable_type"
    t.bigint "authenticatable_id"
    t.datetime "timeout_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "claimed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "token_digest"
    t.string "identifier"
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
    t.index ["token_digest"], name: "index_passwordless_sessions_on_token_digest"
  end

  create_table "pictures", force: :cascade do |t|
    t.string "parent_type"
    t.bigint "parent_id"
    t.jsonb "file"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["parent_type", "parent_id"], name: "index_pictures_on_parent_type_and_parent_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "last_activity_on"
    t.datetime "summary_email_sent_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "summary_metadata", default: "{}"
    t.jsonb "geojson"
    t.string "name"
    t.string "osm_id"
    t.json "translations", default: {}, null: false
    t.string "bounds", default: [], array: true
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "starting_at", precision: nil
    t.string "time_zone"
    t.jsonb "questions", default: {}
    t.bigint "user_id"
    t.index ["event_id"], name: "index_registrations_on_event_id"
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "stashes", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key"], name: "index_stashes_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.string "street"
    t.string "city"
    t.string "country_code"
    t.string "post_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "region_code", limit: 3
    t.string "place_id"
    t.date "last_activity_on"
    t.string "time_zone"
    t.index ["place_id"], name: "index_venues_on_place_id", unique: true
  end

end
