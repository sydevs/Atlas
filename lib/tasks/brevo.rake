namespace :brevo do
  desc 'Create brevo webhook for inbound emails'
  task inbound_webhook: :environment do
    require 'uri'
    require 'net/http'

    url = URI("https://api.brevo.com/v3/webhooks")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = 'application/json'
    request["content-type"] = 'application/json'
    request["api-key"] = ENV['BREVO_API_KEY']
    request.body = "{\"type\":\"inbound\",\"events\":[\"inboundEmailProcessed\"],\"url\":\"https://atlas.sydevelopers.com/cms/messages/receive\",\"domain\":\"reply.sydevelopers.com\",\"batched\":true}"

    response = http.request(request)
    puts response.read_body
  end
end
