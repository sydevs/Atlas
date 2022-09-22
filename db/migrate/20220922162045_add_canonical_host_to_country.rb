class AddCanonicalHostToCountry < ActiveRecord::Migration[6.1]
  def change
    add_column :countries, :canonical_domain, :string, null: true, default: nil
  end
end
