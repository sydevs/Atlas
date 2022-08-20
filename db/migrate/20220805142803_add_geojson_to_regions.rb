class AddGeojsonToRegions < ActiveRecord::Migration[6.1]
  def change
    add_column :regions, :geojson, :jsonb
    add_column :regions, :name, :string
    add_column :regions, :osm_id, :integer
  end
end
