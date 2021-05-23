class AddDefaultLanguageToCountry < ActiveRecord::Migration[6.1]
  def change
    add_column :countries, :default_language_code, :string, limit: 2
  end
end
