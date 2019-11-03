class CreateImages < ActiveRecord::Migration[5.1]

  def change
    create_table :pictures do |t|
      t.belongs_to :parent, polymorphic: true
      t.text :file_data
      t.timestamps
    end
  end

end
