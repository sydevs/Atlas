class RenameVenueAddressColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :venues, :municipality, :city
    rename_column :venues, :subnational, :province
  end
end
