class AddProvinceFlagToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :enable_province_management, :boolean
  end
end
