class CreateStash < ActiveRecord::Migration[5.2]
  def change
    create_table :stashes do |t|
      t.string :key
      t.string :value
    end

    add_index :stashes, :key, unique: true
  end
end
