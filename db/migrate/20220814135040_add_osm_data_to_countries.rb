class AddOsmDataToCountries < ActiveRecord::Migration[6.1]
  def change
    add_column :countries, :name, :string
    add_column :countries, :enable_custom_regions, :boolean, default: false
    add_column :countries, :geojson, :jsonb
    add_column :countries, :osm_id, :integer
    add_column :countries, :translations, :json
    
    remove_column :countries, :bounds, :string
    add_column :countries, :bounds, :string, array: true, default: []

    remove_column :regions, :bounds, :jsonb
    add_column :regions, :bounds, :string, array: true, default: []
  end
end
