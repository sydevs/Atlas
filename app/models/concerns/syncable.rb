module Syncable

  extend ActiveSupport::Concern

  included do
    scope :desynced, -> { where("#{table_name}.updated_at >= ?", MapboxSync.last_synced_at) }
    scope :synced, -> { where("#{table_name}.updated_at < ?", MapboxSync.last_synced_at) }
  end

  def syncing?
    return false if MapboxSync.last_synced_at.nil?

    synced? && MapboxSync.syncing?
  end

  def synced?
    return false if MapboxSync.active_sync_at.nil?

    updated_at < MapboxSync.active_sync_at
  end

end
