require 'shrine'

if Rails.env.development?
  require 'shrine/storage/file_system'
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads'),
  }
else
  require 'shrine/storage/google_cloud_storage'
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::GoogleCloudStorage.new(bucket: ENV['GCLOUD_BUCKET']),
  }
end

Shrine.plugin :activerecord # loads Active Record integration
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data # extracts metadata for assigned cached files
Shrine.plugin :upload_endpoint, url: true, max_size: 5 * 1024 * 1024 # 5 MB  # Allow async uploads with Uppy
Shrine.plugin :derivatives # For image processing / versions
