class CleanUpDatabase < ActiveRecord::Migration[6.1]
  def change
    # remove_column :regions, :province_code, :string, limit: 2
    # remove_column :areas, :province_code, :string, limit: 2

    # remove_column :venues, :street, :string
    # remove_column :venues, :city, :string
    # remove_column :venues, :country_code, :string
    # remove_column :venues, :postcode, :string
  end
end
