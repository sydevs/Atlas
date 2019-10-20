# Sahaj Atlas

## API
There are currently two primary endpoints available. Accessing these endpoints will also provide endpoints to access individual records in the response.
 - `/api/venues.json`
 - `/api/events.json`

Both these endpoints return respond to the following query parameters.
 - `include=?` to include nested records (eg. `events`, `venues`). Comma-separated when you need to specify multiple types of nested records.
 - `latitude=?&longitude=?&radius=?` to restrict the results to a geographical location. `radius` is optional, and will default to 500km.
 