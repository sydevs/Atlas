class AddSubtitleToArea < ActiveRecord::Migration[6.1]
  def change
    add_column :areas, :subtitle, :string
  end
end
