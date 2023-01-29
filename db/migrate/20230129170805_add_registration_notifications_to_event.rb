class AddRegistrationNotificationsToEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :registration_notification, :integer, default: 0, null: false
  end
end
