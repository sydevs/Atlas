## WIX
# This concern simplifies requests to Wix

module WixAPI
  module Event
    SETUP_COMPLETE = 'APP_FINISHED_CONFIGURATION'
  end

  def self.fetch_tokens auth_code
    puts "FETCH TOKENS WITH [#{auth_code.inspect}]"
    response = HTTParty.post('https://www.wix.com/oauth/access', {
      headers: {
        'Content-Type' => 'application/json',
      },
      body: {
        grant_type: 'authorization_code',
        client_id: ENV.fetch('WIX_APP_ID'),
        client_secret: ENV.fetch('WIX_SECRET_KEY'),
        code: auth_code,
      }.to_json,
    })

    puts "FETCH TOKENS #{response.pretty_inspect}"
    response
  end

  def self.refresh_tokens refresh_token
    puts "REFRESH TOKENS WITH [#{refresh_token.inspect}]"
    response = HTTParty.post('https://www.wix.com/oauth/access', {
      headers: {
        'Content-Type' => 'application/json',
      },
      body: {
        grant_type: 'refresh_token',
        client_id: ENV.fetch('WIX_APP_ID'),
        client_secret: ENV.fetch('WIX_SECRET_KEY'),
        refresh_token: refresh_token,
      }.to_json,
    })

    puts "REFRESH TOKENS #{response.pretty_inspect}"
    response
  end

  def self.fetch_site_properties token
    puts "FETCH SITE PROPS WITH [#{token.inspect}]"
    response = HTTParty.get('https://www.wixapis.com/apps/v1/instance', {
      headers: {
        'Authorization' => token,
        'Content-Type' => 'application/json',
      },
    })

    puts "FETCH SITE PROPS #{response.pretty_inspect}"
    response
  end

  def self.close_window token
    puts "CLOSE WINDOW WITH [#{token.inspect}]"
    response = HTTParty.get("https://www.wix.com/installer/close-window?access_token=#{token}")

    puts "CLOSE WINDOW #{response.pretty_inspect}"
    response
  end

  def self.send_event event
    response = HTTParty.post('https://www.wixapis.com/apps/v1/bi-event', {
      body: {
        eventName: event
      },
    })

    puts "SEND EVENT #{event} #{response.pretty_inspect}"
    response
  end

  def self.parse_instance instance
    signature, encoded_json = signed_instance.split('.', 2)
 
    # Need to add Base64 padding to make base64 decode work in Ruby. (ref: http://stackoverflow.com/questions/4987772/decoding-facebooks-signed-request-in-ruby-sinatra)
    encoded_json_hack = encoded_json + ('=' * (4 - encoded_json.length.modulo(4)))
    json_str = Base64.decode64(encoded_json_hack)
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, ENV.fetch('WIX_SECRET_KEY'), encoded_json)
 
    # bug in ruby. why are there '=' chars on urlsafe_encode ?!
    my_signature = Base64.urlsafe_encode64(hmac).gsub('=','')
    raise "the signatures do not match" if (signature != my_signature)

    JSON.parse(json_str)
  end

end
