class AddPlaceIdToVenues < ActiveRecord::Migration[5.2]
  def change
    add_column :venues, :place_id, :string
  end
end
