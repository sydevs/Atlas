class CleanUpDatabase < ActiveRecord::Migration[6.1]
  def change
    remove_column :regions, :province_code, :string, limit: 2
    remove_column :areas, :province_code, :string, limit: 2

    remove_column :managers, :managed_countries_counter, :integer
    remove_column :managers, :managed_localities_counter, :integer

    rename_column :venues, :province_code, :region_code
    rename_column :venues, :postcode, :post_code
    remove_column :venues, :published, :boolean, default: true
    remove_column :venues, :address, :string

    # remove_column :events, :room, :string

    reversible do |dir|
      dir.up do
        [Country, Region].each do |model|
          model.where(translations: nil).update_all(translations: {})
          change_column model.table_name, :translations, :json, default: {}, null: false
          change_column model.table_name, :osm_id, :string, null: true
          model.where(osm_id: '0').update_all(osm_id: 'custom')
          model.where.not(osm_id: [nil, 'custom']).update_all('osm_id = CONCAT(\'R\', osm_id)')
        end
      end
      dir.down do
        [Country, Region].each do |model|
          model.where(osm_id: 'custom').update_all(osm_id: '0')
          model.where.not(osm_id: [nil, '0']).update_all('osm_id = RIGHT(osm_id, -1)')
          change_column model.table_name, :osm_id, :integer, using: 'osm_id::integer'
        end
      end
    end
  end
end
