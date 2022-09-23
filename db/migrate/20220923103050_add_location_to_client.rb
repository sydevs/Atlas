class AddLocationToClient < ActiveRecord::Migration[6.1]
  def change
    add_reference :clients, :location, polymorphic: true, index: true
    remove_column :countries, :canonical_domain, :string
  end
end
