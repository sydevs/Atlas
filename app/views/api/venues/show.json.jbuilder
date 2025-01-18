
json.id @venue.id
json.path venue_path(@venue)
json.url @venue.canonical_url

json.label @venue.label
json.parentPath polymorphic_path([@venue.parent, nil])
json.latitude @venue.latitude
json.longitude @venue.longitude
json.events @venue.events.publicly_visible, partial: 'api/events/event', as: :event
