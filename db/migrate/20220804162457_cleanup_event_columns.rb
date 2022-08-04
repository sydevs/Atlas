class CleanupEventColumns < ActiveRecord::Migration[6.1]
  def up
    Event.where(online: false).update_all(type: 'OfflineEvent')
    Event.where(online: true).update_all(type: 'OnlineEvent')

    remove_column :events, :online, :boolean
    remove_reference :events, :location, index: true, polymorphic: true
  end

  def down
    add_reference :events, :location, index: true, polymorphic: true
    add_column :events, :online, :boolean, null: false
    
    Event.where(type: 'OnlineEvent').update_column(online: true)
    Event.where(type: 'OfflineEvent').update_column(online: false)
  end
end
