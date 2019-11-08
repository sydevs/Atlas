class RemoveAuthorizationsTable < ActiveRecord::Migration[5.1]

  def change
    drop_table :authorizations do |t|
      t.belongs_to :model, polymorphic: true
      t.string :uuid
      t.timestamps
    end
  end

end
