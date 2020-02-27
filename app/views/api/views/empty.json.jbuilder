json.status 'empty'
json.code response.status
json.results do
  json.message "#{translate('map.listing.no_results')} #{}"
  json.latitude @coordinates[0]
  json.longitude @coordinates[1]

  json.alternatives do
    json.array! @alternatives do |alternative|
      json.label alternative[:label]
      json.url api_venues_url(latitude: alternative[:latitude], longitude: alternative[:longitude])
      json.distance alternative[:distance]
      
      json.query do
        json.text alternative[:label]
        json.latitude alternative[:latitude]
        json.longitude alternative[:longitude]
      end
    end
  end
end