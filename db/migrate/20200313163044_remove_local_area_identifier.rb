class RemoveLocalAreaIdentifier < ActiveRecord::Migration[5.2]
  def change
    remove_column :local_areas, :identifier, :string
  end
end
