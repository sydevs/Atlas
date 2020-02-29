class AddCountersToManagers < ActiveRecord::Migration[5.2]
  def change
    add_column :managers, :managed_countries_counter, :integer, default: 0, null: false
    add_column :managers, :managed_localities_counter, :integer, default: 0, null: false
    add_column :managers, :managed_events_counter, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Manager.find_each do |manager|
          counters = {
            managed_countries_counter: manager.countries.count,
            managed_localities_counter: manager.provinces.count + manager.local_areas.count,
            managed_events_counter: manager.events.count,
          }
    
          manager.update_attributes!(counters)
        end
      end
    end
  end
end
