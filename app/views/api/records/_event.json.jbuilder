json.url api_event_url(event, format: :json)
json.extract! event, :id, :label, :description, :category, :languages
if @include.include?(:venue) || @include.include?(:venues)
  json.extract! event, :room
  json.address_text event.room ? "#{event.room}, #{event.venue.full_address}" : event.venue.full_address
else
  json.address_text event.room ? "#{event.room}, #{event.venue.full_address}" : event.venue.full_address
  json.address do
    json.extract! event, :room
    json.extract! event.venue, :street, :city, :province_code, :province_name, :country_code, :country_name, :postcode
  end
end  

json.upcoming_dates event.upcoming_dates.map(&:to_s)

json.timing_text event.timing_in_words
json.timing do
  json.extract! event, :recurrence, :start_date, :end_date, :start_time, :end_time
end

if !local_assigns[:nested] && (@include.include?(:venue) || @include.include?(:venues))
  json.venue do
    json.partial! 'api/records/venue', venue: event.venue, nested: true
  end
else
  json.venue api_venue_url(event.venue_id, format: :json)
end