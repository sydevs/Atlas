class RemoveManagerIdFromVenues < ActiveRecord::Migration[5.2]
  def change
    remove_reference :venues, :manager
  end
end
