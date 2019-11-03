class AddPublishedToggle < ActiveRecord::Migration[5.1]

  def change
    add_column :events, :published, :boolean, default: true
    add_column :venues, :published, :boolean, default: true
  end

end
