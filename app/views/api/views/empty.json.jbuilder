json.label params[:label] # TODO: Remove test code
json.status 'empty'
json.code response.status
json.message = "#{translate('map.listing.no_results')} #{}"
json.alternatives do
  json.array! @alternatives do |alternative|
    json.label alternative[:label]
    json.url api_events_url(latitude: alternative[:latitude], longitude: alternative[:longitude])
    json.distance alternative[:distance]
    json.query do
      json.latitude alternative[:latitude]
      json.longitude alternative[:longitude]
    end
  end
end
