class AddNotificationsToEvents < ActiveRecord::Migration[5.1]

  def change
    add_column :events, :disable_notifications, :boolean, default: false, null: false
  end

end
