class SplitRegionsTable < ActiveRecord::Migration[5.1]

  def change
    drop_table :regions do |t|
      t.string :name
      t.string :identifier
      t.string :subnational
      t.string :country_code, length: 2
      t.float :latitude
      t.float :longitude
      t.float :radius
      t.integer :restriction, default: 0
      t.timestamps
    end

    drop_join_table :managers, :regions

    create_table :countries do |t|
      t.string :country_code, length: 2, null: false
      t.string :identifier
      t.timestamps
    end

    create_table :provinces do |t|
      t.string :country_code, length: 2, null: false
      t.string :province_name
      t.string :identifier
      t.timestamps
    end

    create_table :local_areas do |t|
      t.string :country_code, length: 2, null: false
      t.string :province_name
      t.string :name
      t.string :identifier
      t.float :latitude
      t.float :longitude
      t.float :radius
      t.timestamps
    end

    add_index :countries, :country_code, unique: true
    add_index :provinces, :province_name, unique: true

    create_table :managed_regions, id: false do |t|
      t.integer :manager_id
      t.integer :region_id
      t.string  :region_type
    end

    add_index :managed_regions, %i[region_id region_type]
  end

end
