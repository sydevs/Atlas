SibApiV3Sdk.configure do |config|
  # Configure API key authorization: api-key
  config.api_key['api-key'] = ENV['BREVO_API_KEY']

  # Set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['api-key'] = 'Bearer'

  config.debugging = true
end
