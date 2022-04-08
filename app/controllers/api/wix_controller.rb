class API::WixController < API::ApplicationController
  skip_before_action :authenticate_client!

  def auth
    redirect_to "https://www.wix.com/installer/install?#{{
      token: params[:token],
      appId: ENV.fetch('WIX_APP_ID'),
      redirectUrl: api_wix_setup_url,
    }.to_query}"
  end

  def setup
    tokens = WixAPI.fetch_tokens(params[:code])
    data = WixAPI.fetch_site_properties(tokens['access_token'])
    @client = Client.new({
      client_type: :wix,
      label: "#{data['site']['siteDisplayName']} (Wix)",
      secret_key: SecureRandom.uuid,
      public_key: data['instance']['instanceId'],
      external_id: data['instance']['instanceId'],
      external_token: tokens['refresh_token'],
      domain: URI(data['site']['url'] || "").host,
      # default_config: {
      #   locale: data['site']['locale']
      # },
    })

    email = data['site']['ownerInfo']['email'].downcase
    @client.manager = Manager.find_or_create_by(email: email) do |new_manager|
      new_manager.name = email.split('@').first.humanize
      new_manager.language_code = data['site']['locale']
      new_manager.email_verified = data['site']['ownerInfo']['emailStatus'].starts_with?("VERIFIED")
    end

    tokens = WixAPI.refresh_tokens(tokens['refresh_token'])
    @client.external_token = tokens['refresh_token']
    @client.save!
    WixAPI.close_window(tokens['access_token'])
  end

  def settings
    # WixAPI.send_event(WixAPI::Event::SETUP_COMPLETE)
  end

  def dashboard

  end

end
