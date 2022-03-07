class AddWixToClients < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :wix_id, :string
    add_column :clients, :approved, :boolean, null: false, default: false
    add_index :clients, :wix_id, unique: true
    add_index :clients, :approved, where: 'approved'
  end
end
