module MapboxSync

  def self.last_synced_at
    Stash.get('last_synced_at')
  end

  def self.next_sync_at
    @@next_sync_at ||= begin
      if MapboxSync.last_synced_at && MapboxSync.last_synced_at > 1.hour.ago
        (MapboxSync.last_synced_at + 1.hour).beginning_of_hour
      else
        1.hour.from_now.beginning_of_hour
      end
    end
  end

  def self.can_sync?
    MapboxSync.last_synced_at < 1.hour.ago
  end

  def self.syncing?
    MapboxSync.next_sync_at <= DateTime.now || MapboxSync.last_synced_at > 5.minutes.ago
  end

  def self.sync!
    
  end

end
