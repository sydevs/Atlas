class AddClientTable < ActiveRecord::Migration[6.1]
  def change
    create_table :clients do |t|
      t.string :label, null: false
      t.jsonb :config, null: false, default: '{}'
      t.string :domain, null: false
      t.references :manager, null: false
      t.string :public_key, null: false
      t.string :secret_key, null: false
      t.boolean :enabled, null: false, default: true
      t.datetime :last_accessed_at
      t.timestamps
    end
  end
end
