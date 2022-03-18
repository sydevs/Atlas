require 'httparty'

## MESSAGEBIRD
# This concern simplifies requests to messagebird api

module MessageBirdAPI
  CHANNELS = {
    whatsapp: '',
    telegram: 'd2b725c0673946a7addc77422ffe8040',
    wechat: '',
  }.freeze

  def self.send message, manager, parameters = {}
    puts "MESSAGEBIRD SEND #{message} to #{manager.name} via #{manager.contact_method}"
    response = HTTParty.post('https://conversations.messagebird.com/v1/conversations/start', {
      headers: {
        'Authorization' => "AccessKey #{ENV.fetch('MESSAGEBIRD_API_KEY')}",
        'Content-Type' => 'application/json',
      },
      body: {
        to: manager.phone.delete('^0-9'),
        channelId: '2ee92f7658834f1aa19548fafbcfafe9', # CHANNELS[manager.contact_method.to_sym],
        type: "hsm",
        content: {
          hsm: {
            namespace: '425e40e8_71fc_46ab_80f2_3aad657a385b',
            templateName: message.to_s,
            params: [
              { default: 'Roberto Test' },
              { default: '123' },
              { default: 'new coffee machine' },
              { default: 'MessageBird, Trompenburgstraat 2C, 1079TX Amsterdam' }
            ],
            language: {
              policy: 'deterministic',
              code: manager.language_code,
            },
          }
        },
      }.to_json,
      debug_output: $stdout,
    })

=begin
    response = HTTParty.post('https://conversations.messagebird.com/v1/send', {
      headers: {
        'Authorization' => "AccessKey #{ENV.fetch('MESSAGEBIRD_API_KEY')}",
        'Content-Type' => 'application/json',
      },
      body: {
        to: manager.phone,
        from: CHANNELS[manager.contact_method.to_sym],
        type: "text",
        content: { text: message },
      }.to_json,
    })
=end
  end

end
