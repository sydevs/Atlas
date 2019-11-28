json.status 'empty'
json.code response.status
json.message = "#{translate('map.listing.no_results')} #{}"
json.alternative do
  json.label @alternative[:label]
  json.url api_events_url(latitude: @alternative[:latitude], longitude: @alternative[:longitude])
  json.query do
    json.latitude @alternative[:latitude]
    json.longitude @alternative[:longitude]
  end
end
