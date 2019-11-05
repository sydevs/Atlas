class AddImagesToEvent < ActiveRecord::Migration[5.1]

  def change
    add_column :events, :images, :jsonb
  end

end
