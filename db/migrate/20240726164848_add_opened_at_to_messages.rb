# typed: ignore
class AddOpenedAtToMessages < ActiveRecord::Migration[4.2]
  class MigrationMessage < ActiveRecord::Base
    self.table_name = :messages
  end

  def self.up
    add_column :messages, :opened_at, :datetime
    MigrationMessage.where(opened: true).update_all(opened_at: DateTime.now)
  end

  def self.down
    MigrationMessage.where('opened_at is not null').update_all(opened: true)
    remove_column :messages, :opened_at
  end
end
