CarrierWave.configure do |config|
  if ENV['GCLOUD_BUCKET'].present?
    config.storage = :fog
    config.asset_host = "https://#{ENV.fetch('GCLOUD_BUCKET')}" if ENV['GCLOUD_BUCKET'].include?('.')

    config.fog_provider = 'fog/google'
    config.fog_directory = ENV.fetch('GCLOUD_BUCKET')
    config.fog_attributes = { expires: 600 }
    config.fog_credentials = {
      provider:               'Google',
      google_project:         'sahaj-atlas',
      google_json_key_string: ENV.fetch('GOOGLE_CLOUD_KEYFILE', nil),
    }
  else
    config.storage = :file
  end
end
