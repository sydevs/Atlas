class CreateRegionsTable < ActiveRecord::Migration[5.1]

  def change
    create_table :regions do |t|
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

    create_join_table :managers, :regions
  end

end
