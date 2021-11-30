class AddLocaleToManager < ActiveRecord::Migration[6.1]
  def change
    add_column :managers, :language_code, :string, limit: 2, default: 'EN'
  end
end
