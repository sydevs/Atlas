class CleanUpDatabase < ActiveRecord::Migration[6.1]
  def change
    # remove_column :regions, :province_code, :string, limit: 2
    # remove_column :areas, :province_code, :string, limit: 2

    # remove_column :venues, :street, :string
    # remove_column :venues, :city, :string
    # remove_column :venues, :country_code, :string
    # remove_column :venues, :postcode, :string

    reversible do |dir|
      dir.up do
        [Country, Region].each do |model|
          change_column model.table_name, :osm_id, :string, null: true
          model.where.not(osm_id: nil).update_all('osm_id = CONCAT(\'R\', osm_id)')
        end
      end
      dir.down do
        [Country, Region].each do |model|
          model.where.not(osm_id: nil).update_all('osm_id = RIGHT(osm_id, -1)')
          change_column model.table_name, :osm_id, :integer, using: 'osm_id::integer'
        end
      end
    end
  end
end
