## WIX
# This concern simplifies requests to Wix

module WixAPI
  module Event
    SETUP_COMPLETE = 'APP_FINISHED_CONFIGURATION'
  end

  def self.fetch_tokens refresh_token: nil, auth_code: nil
    HTTParty.post('https://www.wix.com/oauth/access', {
      body: {
        grant_type: auth_code ? 'authorization_code' : 'refresh_token',
        client_id: ENV.fetch('WIX_APP_ID'),
        client_secret: ENV.fetch('WIX_SECRET_KEY'),
        code: auth_code ? auth_code : nil,
        refresh_token: !auth_code ? refresh_token : nil,
      }
    })
  end

  def self.fetch_site_properties token
    HTTParty.get('https://www.wixapis.com/apps/v1/instance', {
      headers: {
        'Authorization' => token
      }
    })
  end

  def self.close_window token
    HTTParty.get("https://www.wix.com/installer/close-window?access_token=#{token}")
  end

  def self.send_event event
    HTTParty.post('https://www.wixapis.com/apps/v1/bi-event', {
      body: {
        eventName: event
      }
    })
  end

end
