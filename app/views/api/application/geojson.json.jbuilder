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
      if venue.publicly_visible_events.count != 1
        json.id venue.id
        json.type 'venue'
        json.address venue.address
      else
        event = venue.publicly_visible_events.first
        json.id event.id
        json.type 'event'
        json.address venue.address
      end
    end
  end
end