class AddNotificationsFlagToManagers < ActiveRecord::Migration[6.1]
  def change
    add_column :managers, :notifications, :integer, null: false, default: 2147483647
    remove_column :events, :disable_notifications, :boolean, default: false, null: false
  end
end
