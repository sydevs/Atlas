class RemoveEventsCounterFromManagers < ActiveRecord::Migration[5.2]
  def change
    remove_column :managers, :managed_events_counter, :integer
  end
end
