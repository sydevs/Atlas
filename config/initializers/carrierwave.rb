CarrierWave.configure do |config|
  config.asset_host = ActionController::Base.asset_host

  if ENV['GCLOUD_BUCKET'].present?
    config.storage = :gcloud
    config.asset_host = "https://#{ENV.fetch('GCLOUD_BUCKET')}" if ENV.fetch('GCLOUD_BUCKET').include?('.')
    config.gcloud_bucket = ENV.fetch('GCLOUD_BUCKET')
    config.gcloud_bucket_is_public = true
    config.gcloud_authenticated_url_expiration = 600

    config.gcloud_attributes = { expires: 600 }
    config.gcloud_credentials = {
      gcloud_project: 'sahaj-atlas',
      gcloud_keyfile: JSON.parse(ENV.fetch('GOOGLE_CLOUD_KEYFILE')),
    }
  else
    config.storage = :file
  end
end
