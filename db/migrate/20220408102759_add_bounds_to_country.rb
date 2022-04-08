class AddBoundsToCountry < ActiveRecord::Migration[6.1]
  def change
    add_column :countries, :bounds, :string
  end
end
