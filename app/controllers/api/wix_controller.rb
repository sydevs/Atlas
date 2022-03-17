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
    puts "SETUP #{params.pretty_inspect}"
    tokens = WixAPI.get_tokens(params[:code], auth: true)
    @client = Client.create({
      label: "Wix App #{params[:instanceId]}",
      secret_key: SecureRandom.uuid,
      public_key: SecureRandom.uuid,
      wix_id: params[:instanceId],
      refresh_token: tokens['refresh_token'],
    })

    WixAPI.close_window(tokens['access_token'])
  end

  def settings
    # WixAPI.send_event(WixAPI::Event::SETUP_COMPLETE)
  end

  def dashboard

  end

end
