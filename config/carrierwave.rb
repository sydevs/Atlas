CarrierWave.configure do |config|
  config.storage = Rails.env.production? ? :gcloud : :file
  config.asset_host = ActionController::Base.asset_host
  config.gcloud_bucket = 'sydirectory'
  config.gcloud_bucket_is_public = true
  config.gcloud_authenticated_url_expiration = 600

  config.gcloud_attributes = { expires: 600 }
  config.gcloud_credentials = {
    gcloud_project: 'sydirectory',
    gcloud_keyfile: JSON.parse(ENV['GOOGLE_CLOUD_KEYFILE'])
  }
end
