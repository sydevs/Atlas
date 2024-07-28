class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.string :brevo_id, null: true, index: true
      t.integer :category, default: 0, null: false, index: true
      t.references :channel, polymorphic: true
      t.references :account, polymorphic: true
      t.jsonb :data

      t.timestamps
    end
  end
end
