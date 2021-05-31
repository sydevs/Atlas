class AddTimezoneToVenue < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :time_zone, :string
  end
end
