class AddAdminToManagers < ActiveRecord::Migration[5.1]

  def change
    add_column :managers, :administrator, :boolean
  end

end
