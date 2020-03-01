class MakeManagersUnique < ActiveRecord::Migration[5.2]
  def change
    remove_index :managers, :email
    add_index :managers, :email, unique: true
  end
end
