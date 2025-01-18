
json.id @venue.id
json.path venue_path(@venue)
json.url venue_url(@venue, host: @venue.canonical_host)

json.label @venue.label
json.parentPath polymorphic_path([@venue.parent, nil])
json.latitude @venue.latitude
json.longitude @venue.longitude
json.events @venue.events.publicly_visible, partial: 'api/events/event', as: :event
