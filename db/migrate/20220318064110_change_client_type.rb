class ChangeClientType < ActiveRecord::Migration[6.1]
  def change
    rename_column :clients, :type, :client_type
  end
end
