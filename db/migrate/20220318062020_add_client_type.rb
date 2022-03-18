class AddClientType < ActiveRecord::Migration[6.1]
  def change
    remove_index :clients, :approved, where: 'approved'
    remove_column :clients, :approved, :boolean, null: false, default: false

    add_column :clients, :type, :integer, default: 0, null: false
    rename_column :clients, :wix_id, :external_id
    rename_column :clients, :wix_refresh_token, :external_token
  end
end
