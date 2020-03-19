class RenameLanguageToLanguageCode < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :language, :language_code
  end
end
