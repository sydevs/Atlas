class AddManagerContactOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :managers, :contact_method, :integer, default: 0, null: false
    add_column :managers, :phone, :string
    add_column :managers, :phone_verified, :boolean, default: false
    add_column :managers, :phone_verification_sent_at, :datetime
    add_index :managers, :phone, unique: true

    add_column :managers, :contact_settings, :json, default: {}
  end
end
