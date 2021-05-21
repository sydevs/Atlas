CarrierWave.configure do |config|
  config.asset_host = "https://#{ENV['GCLOUD_BUCKET']}" if ENV['GCLOUD_BUCKET']

  if ENV['GCLOUD_BUCKET'].present?
    # If the bucket name looks like a host name use it as asset_host.
    # For example "wemeditate" is treated as bucket only with URL's like:
    # https://storage.googleapis.com/wemeditate/uploads/<carrier-wave-path>
    # while "assets.wemeditate.co" is treated as a host with URL's like:
    # https://assets.wemeditate.co/uploads/<carrier-wave-path>
    config.gcloud_bucket = ENV['GCLOUD_BUCKET']
    config.asset_host = "https://#{ENV['GCLOUD_BUCKET']}" if ENV['GCLOUD_BUCKET'].include?('.')
    config.gcloud_bucket_is_public = true
    config.gcloud_authenticated_url_expiration = 600
    config.gcloud_attributes = { expires: 600 }
    config.gcloud_credentials = {
      gcloud_project: 'sahaj-atlas',
      gcloud_keyfile: ENV['GOOGLE_CLOUD_KEYFILE'].present? ? JSON.parse(ENV['GOOGLE_CLOUD_KEYFILE']) : nil,
    }

    config.storage = :gcloud
  else
    config.storage = :file
  end
end
