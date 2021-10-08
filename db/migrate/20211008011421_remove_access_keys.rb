class RemoveAccessKeys < ActiveRecord::Migration[6.1]
  def up
    drop_table :access_keys, if_exists: true
  end
end
