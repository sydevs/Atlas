class API::GraphqlController < API::ApplicationController
  skip_before_action :authenticate_client!

  def auth
    @client = Client.new
    redirect_to "https://www.wix.com/installer/install?#{{
      token: params[:token],
      appId: ENV.fetch['WIX_APP_ID'],
      redirectUrl: api_wix_login_url,
      state: @client.id
    }.to_query}}"
  end

  def setup
    auth_code = params[:code]
    @client = Client.find(params[:state])
    @client.wix_id = params[:instanceId]
    tokens = WixAPI.get_tokens(auth_code, auth: true)
    @client.update_column refresh_token: tokens['refresh_token']
    WixAPI.close_window(tokens['access_token'])
  end

  def config
    WixAPI.send_event(WixAPI::Event::SETUP_COMPLETE)
  end

end
