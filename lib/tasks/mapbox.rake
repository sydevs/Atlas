require 'httparty'
require 'aws-sdk-s3'

namespace :mapbox do
  desc 'Generate a new geojson file from the current database'
  task update: :environment do
    include LocalizationHelper
    file = Tempfile.new('mapbox-data')
    features = []

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

    puts "----------"
    url = "https://api.mapbox.com/uploads/v1/#{ENV.fetch('MAPBOX_USERNAME')}/credentials?access_token=#{ENV.fetch('MAPBOX_SECRET_ACCESSTOKEN')}"
    response = HTTParty.post(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })
    puts response.parsed_response.inspect
    puts "----------"

    bucket = response['bucket']
    file_key = response['key']

    s3 = Aws::S3::Resource.new({
      access_key_id: response['accessKeyId'],
      secret_access_key: response['secretAccessKey'],
      session_token: response['sessionToken'],
      region: 'us-east-1'
    })
    obj = s3.bucket(bucket).object(file_key)
    puts obj.upload_file(file.path)
    puts "----------"

    url = "https://api.mapbox.com/uploads/v1/#{ENV.fetch('MAPBOX_USERNAME')}?access_token=#{ENV.fetch('MAPBOX_SECRET_ACCESSTOKEN')}"
    options = {
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      },
      body: {
        url: "http://#{bucket}.s3.amazonaws.com/#{file_key}",
        tileset: "#{ENV.fetch('MAPBOX_USERNAME')}.meditation-venues",
      }.to_json,
      log_level: :debug,
    }
    puts url.inspect
    puts options.inspect
    response = HTTParty.post(url, options)
    puts response.parsed_response.inspect
    puts "----------"

    file.unlink
  end
end
