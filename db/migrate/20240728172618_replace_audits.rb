class ReplaceAudits < ActiveRecord::Migration[7.0]
  def change
    drop_table "audits", id: :serial do |t|
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

    create_table :conversations do |t|
      t.datetime :marked_complete_at
      t.datetime :last_response_at
      t.references :last_responder, polymorphic: true
      t.references :parent, polymorphic: true
      t.string :uuid, null: false, index: true
      t.timestamps
    end

    create_table :audits do |t|
      t.integer :category, default: 0, null: false, index: true
      t.references :parent, polymorphic: true
      t.references :person, polymorphic: true
      t.references :replies_to
      t.references :replied_by
      t.references :conversation
      t.jsonb :data
      t.timestamps
    end
  end
end
