
json.id @venue.id
json.label @venue.label
json.events @venue.events, partial: 'api/events/event', as: :event
