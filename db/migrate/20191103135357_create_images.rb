class CreateImages < ActiveRecord::Migration[5.1]

  def change
    create_table :pictures do |t|
      t.belongs_to :parent, polymorphic: true
      t.jsonb :file
      t.timestamps
    end
  end

end
