class UpdateEventColumns < ActiveRecord::Migration[5.2]
  def up
    remove_column :events, :languages
    add_column :events, :language, :string, limit: 2
    change_column :events, :description, :string, limit: 600
  end

  def down
    change_column :events, :description, :string, limit: nil
    remove_column :events, :language
    add_column :events, :languages, :string, array: true
  end
end
