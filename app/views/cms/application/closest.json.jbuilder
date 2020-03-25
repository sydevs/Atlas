json.latitude @venue.latitude
json.longitude @venue.longitude

if @event
  json.close true
  json.venue @venue.as_json
  json.event @event.as_json
else
  json.close false
  json.label "#{@venue.city || @venue.province_name}, #{@venue.country_code}"
end
