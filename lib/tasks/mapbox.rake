require 'httparty'
require 'aws-sdk-s3'

namespace :mapbox do
  desc 'Generate a new geojson file from the current database'
  task update: :environment do
    if Venue.where('updated_at >= ?', 2.hours.ago).exists? || Event.where('updated_at >= ?', 2.hours.ago).exists?
      Rake::Task['mapbox:update:force'].invoke
    else
      puts "No changes to the data in the past 2 hours"
    end
  end

  namespace :update do
    task force: :environment do
      include LocalizationHelper
      file = Tempfile.new('meditation-venues.geojson')
      username = ENV.fetch('MAPBOX_USERNAME')
      token = ENV.fetch('MAPBOX_SECRET_ACCESSTOKEN')
      tileset = "#{username}.meditation-venues"
      features = []
  
      puts "===== GENERATE NEW DATASET ====="
      Venue.includes(:events).published.find_each do |venue|
        next unless venue.events.present?
        venue.extend VenueDecorator
  
        features << {
          type: 'Feature',
          id: venue.id,
          geometry: {
            type: 'Point',
            coordinates: [venue.longitude, venue.latitude]
          },
          properties: venue.to_h,
        }
      end
  
      file.write({
        type: 'FeatureCollection',
        features: features,
      }.to_json)
  
      puts file.path
      file.rewind
      puts JSON.parse(file.read).pretty_inspect
  
      puts "===== RETRIEVE AWS CREDENTIALS ====="
      url = "https://api.mapbox.com/uploads/v1/#{username}/credentials?access_token=#{token}"
      response = HTTParty.post(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })
      puts "--> #{response.parsed_response.inspect}"
  
      bucket = response['bucket']
      file_key = response['key']
  
      puts "===== UPLOAD DATASET TO AWS S3 ====="
      s3 = Aws::S3::Resource.new({
        access_key_id: response['accessKeyId'],
        secret_access_key: response['secretAccessKey'],
        session_token: response['sessionToken'],
        region: 'us-east-1'
      })
      obj = s3.bucket(bucket).object(file_key)
      puts obj.upload_file(file.path)
  
      puts "===== UPLOAD DATASET TO MAPBOX ====="
      url = "https://api.mapbox.com/uploads/v1/#{username}?access_token=#{token}"
      options = {
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
        body: {
          url: "http://#{bucket}.s3.amazonaws.com/#{file_key}",
          tileset: tileset,
        }.to_json,
        log_level: :debug,
      }
      puts url.inspect
      puts options.inspect
      response = HTTParty.post(url, options)
      puts "--> #{response.parsed_response.inspect}"
  
      file.unlink
    end
  end
end
