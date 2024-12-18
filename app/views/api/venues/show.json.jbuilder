
json.id @venue.id
json.label @venue.label
json.parentId @venue.parent.id
json.parentType @venue.parent.class.model_name.singular
json.latitude @venue.latitude
json.longitude @venue.longitude
json.events @venue.events, partial: 'api/events/event', as: :event
