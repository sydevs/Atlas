class CreateLocalAreaVenuesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :local_area_venues do |t|
      t.belongs_to :local_area
      t.belongs_to :venue
      t.timestamps
    end
  end
end
