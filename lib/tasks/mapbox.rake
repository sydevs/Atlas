require 'httparty'
require 'aws-sdk-s3'

namespace :mapbox do
  desc 'Generate a new geojson file from the current database'
  task update: :environment do
    if !MapboxSync.needs_sync?
      puts "Skipping Mapbox Sync - No changes to the data since the last sync"
    elsif !MapboxSync.can_sync?
      puts "Skipping Mapbox Sync - Last sync was too recent (#{time_ago_in_words MapboxSync.last_synced_at} ago)"
    else
      Rake::Task['mapbox:update:force'].invoke
    end
  end

  namespace :update do
    task test: :environment do
      puts MapboxSync.generate_geojson.pretty_inspect
    end

    task force: :environment do
      MapboxSync.sync!
    end
  end
end
