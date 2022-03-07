## WIX
# This concern simplifies requests to Wix

module WixAPI
  module Event
    SETUP_COMPLETE = 'APP_FINISHED_CONFIGURATION'
  end

  def self.get_tokens token, auth: false
    response = HTTParty.post('https://www.wix.com/oauth/access', {
      body: {
        grant_type: auth ? 'authorization_code' : 'refresh_token',
        client_id: ENV.fetch('WIX_APP_ID'),
        client_secret: ENV.fetch('WIX_SECRET_KEY'),
        code: token,
        refresh_token: token,
      }
    })

    response
  end

  def self.update_site_data client, access_token = nil
    # access_token = self.fetch_refresh_token(client, client.refresh_token) unless access_token.present?search
    # Do nothing for now
  end

  def self.close_window token
    HTTParty.get("https://www.wix.com/installer/close-window?access_token=#{token}")
  end

  def self.send_event event
    HTTParty.post('https://www.wixapis.com/apps/v1/bi-event', {
      body: {
        eventName: "APP_FINISHED_CONFIGURATION"
      }
    })
    end

end
