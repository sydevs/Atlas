class AddDefaultToOnline < ActiveRecord::Migration[5.2]
  def change
    Event.where(online: nil).update_all online: false
    change_column :events, :online, :boolean, default: false, null: false
  end
end
