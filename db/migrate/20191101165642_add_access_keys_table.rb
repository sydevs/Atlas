class AddAccessKeysTable < ActiveRecord::Migration[5.1]

  def change
    create_table :access_keys do |t|
      t.string :label
      t.string :key
      t.boolean :suspended
      t.datetime :last_accessed_at
      t.timestamps
    end
  end

end
