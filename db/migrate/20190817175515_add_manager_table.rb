class AddManagerTable < ActiveRecord::Migration[5.1]
  def change
    create_table :managers do |t|
      t.string :name
      t.string :email, index: true, unique: true
      t.timestamps
    end

    add_reference :venues, :manager, index: true
    add_reference :events, :manager, index: true

    remove_column :events, :contact_name, :string
    remove_column :events, :contact_email, :string
    remove_column :venues, :contact_name, :string
    remove_column :venues, :contact_email, :string
  end
end
