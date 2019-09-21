class MakeLocalAreaCountryNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :local_areas, :country_code, true
  end
end
