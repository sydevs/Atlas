class AddStartingAtToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :starting_at, :datetime
  end
end
