class AddTimezoneToRegistration < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :time_zone, :string
  end
end
