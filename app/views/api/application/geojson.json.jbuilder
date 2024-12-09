json.success true
json.createdAt Time.now.utc.iso8601
json.type "FeatureCollection"

json.features do
  json.array! @venues do |venue|
    json.type "Feature"
    json.geometry do
      json.type "Point"
      json.coordinates [
        venue.longitude.round(6),
        venue.latitude.round(6)
      ]
    end
    json.properties do
      json.id venue.id
      json.address venue.address
      json.eventIds venue.events.publicly_visible.pluck(:id)
    end
  end
end
