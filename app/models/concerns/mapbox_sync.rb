include LocalizationHelper

module MapboxSync

  def self.last_synced_at
    Stash.get(:last_synced_at)
  end

  def self.last_sync_errored_at
    Stash.get(:last_sync_errored_at)
  end

  def self.last_sync_error
    Stash.get(:last_sync_error)
  end

  def self.last_sync_errored?
    MapboxSync.last_sync_errored_at.present?
  end

  def self.current_sync_started_at
    Stash.get(:current_sync_started_at)
  end
  
  # This is the most recent sync that has been started
  def self.active_sync_at
    MapboxSync.current_sync_started_at || MapboxSync.last_synced_at
  end

  def self.next_sync_at
    if MapboxSync.can_sync?
      59.minutes.from_now.beginning_of_hour + 1.minute
    else
      (MapboxSync.can_sync_at + 59.minutes).beginning_of_hour + 1.minute
    end
  end

  def self.needs_sync?
    Venue.where('updated_at >= ?', MapboxSync.last_synced_at).exists? ||
      Event.where('updated_at >= ?', MapboxSync.last_synced_at).exists? ||
      Event.where('updated_at >= ? AND updated_at < ?', 
                  MapboxSync.last_synced_at - Expirable::EXPIRE_AFTER_WEEKS.weeks,
                  DateTime.now - Expirable::EXPIRE_AFTER_WEEKS.weeks).exists?
  end

  def self.can_sync_at
    MapboxSync.active_sync_at.nil? ? DateTime.now : MapboxSync.active_sync_at + 1.hour
  end

  def self.can_sync?
    !MapboxSync.syncing? && MapboxSync.can_sync_at <= DateTime.now
  end

  def self.syncing?
    Stash.get(:current_sync_started_at).present?
  end

  def self.sync!
    Stash.set(:current_sync_started_at, DateTime.now)
    file = Tempfile.new(GeojsonUploader::FILENAME)

    file.write(MapboxSync.generate_geojson.to_json)
    puts "Created geojson file: #{file.path}"

    # remote_file_path = MapboxSync.upload_mapbox_s3! file
    # MapboxSync.publish_to_mapbox! remote_file_path
    MapboxSync.upload_google_storage! file

    Stash.set(:last_synced_at, MapboxSync.current_sync_started_at)
    Stash.set(:current_sync_started_at, nil)
    Stash.set(:last_sync_errored_at, nil)
    Stash.set(:last_sync_error, nil)

    file.unlink
    return true
  rescue StandardError => error
    Stash.set(:last_sync_errored_at, DateTime.now)
    Stash.set(:last_sync_error, "#{error.message} (#{error.class})")
    Stash.set(:current_sync_started_at, nil)
    raise error if Rails.env.development?
    return false
  end

  def self.generate_geojson
    features = []
    venue_count = 0
    event_count = 0

    puts 'Generating geojson dataset...' 
    Venue.includes(:events).published.find_each do |venue|
      next unless venue.events.present?
      venue.extend VenueDecorator
      venue_count += 1
      event_count += venue.events.count

      features << {
        type: 'Feature',
        id: venue.id,
        geometry: {
          type: 'Point',
          coordinates: [venue.longitude, venue.latitude]
        },
        properties: venue.as_json,
      }
    end

    puts "Generated geojson dataset with #{venue_count} venue(s) and #{event_count} event(s)"
    {
      type: 'FeatureCollection',
      features: features,
    }
  end

  def self.get_remote_geojson_url
    uploader = GeojsonUploader.new
    uploader.retrieve_from_store!(GeojsonUploader::FILENAME)
    uploader.url
  end

  private

    def self.upload_mapbox_s3! file
      username = ENV.fetch('MAPBOX_USERNAME')
      token = ENV.fetch('MAPBOX_SECRET_ACCESSTOKEN')

      puts 'Retrieving temporary AWS credentials from Mapbox...' 
      url = "https://api.mapbox.com/uploads/v1/#{username}/credentials?access_token=#{token}"
      puts "--> #{url.inspect}"
      response = HTTParty.post(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })
      puts "<-- #{response.parsed_response.inspect}"
  
      bucket = response['bucket']
      file_key = response['key']
  
      puts 'Uploading dataset to Mapbox\'s AWS S3 bucket...' 
      s3 = Aws::S3::Resource.new({
        access_key_id: response['accessKeyId'],
        secret_access_key: response['secretAccessKey'],
        session_token: response['sessionToken'],
        region: 'us-east-1'
      })
      obj = s3.bucket(bucket).object(file_key)
      result = obj.upload_file(file.path)
      puts "<-- #{result.inspect}"

      "http://#{bucket}.s3.amazonaws.com/#{file_key}"
    end

    def self.upload_google_storage! file
      puts 'Storing dataset to Google Cloud Storage...'
      uploader = GeojsonUploader.new
      uploader.store!(file)
      puts "--> #{MapboxSync.get_remote_geojson_url}"
    end

    def self.publish_to_mapbox! remote_file_url
      username = ENV.fetch('MAPBOX_USERNAME')
      token = ENV.fetch('MAPBOX_SECRET_ACCESSTOKEN')
      tileset = "#{username}.meditation-venues"

      puts 'Publishing dataset to Mapbox...'
      url = "https://api.mapbox.com/uploads/v1/#{username}?access_token=#{token}"
      options = {
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
        body: {
          url: remote_file_url,
          tileset: tileset,
        }.to_json,
        log_level: :debug,
      }
      puts "--> #{url.inspect}"
      response = HTTParty.post(url, options)
      puts "<-- #{response.parsed_response.inspect}"
    end

end
