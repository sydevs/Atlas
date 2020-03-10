class RemoveIdentifierFromRegions < ActiveRecord::Migration[5.2]
  def change
    remove_column :countries, :identifier, :string
    remove_column :provinces, :identifier, :string
  end
end
