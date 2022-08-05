class AddOsmDataToRegions < ActiveRecord::Migration[6.1]
  def change
    add_column :regions, :translations, :json
    add_column :regions, :bounds, :jsonb
  end
end
