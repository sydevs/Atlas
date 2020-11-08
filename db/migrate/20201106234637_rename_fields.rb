class RenameFields < ActiveRecord::Migration[6.0]
  def change
    rename_column :events, :name, :custom_name
  end
end
