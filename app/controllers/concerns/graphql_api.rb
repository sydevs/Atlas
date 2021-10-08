
## GRAPHQL
# This concern mimics the api calls which will be made by the map, so that we can prefill data for the map.

module GraphqlAPI

  EVENT_FRAGMENT = %{
    id
    label
    description
    category
    address
    languageCode
    phoneNumber
    online
    onlineUrl
    registrationMode
    registrationUrl
    venueId
    path
    firstOccurrence
    lastOccurrence
    upcomingOccurrences
    timing {
      duration
      timeZone
    }
    images {
      url
      thumbnailUrl
    }
  }

  VENUE_FRAGMENT = %{
    id
    label
    latitude
    longitude
    directionsUrl
  }

  def self.events online: nil
    AtlasSchema.execute(%{
      query {
        events#{online.nil? ? '' : "(online: #{online})"} {
          #{EVENT_FRAGMENT}
          venue {
            #{VENUE_FRAGMENT}
          }
        }
      }
    })['data']['events']
  end

  def self.event id
    AtlasSchema.execute(%{
      query {
        event(id: #{id}) {
          #{EVENT_FRAGMENT}
          venue {
            #{VENUE_FRAGMENT}
            events {
              #{EVENT_FRAGMENT}
            }
          }
        }
      }
    })['data']['event']
  end

  def self.venue id
    AtlasSchema.execute(%{
      query {
        venue(id: #{id}) {
          #{VENUE_FRAGMENT}
          events {
            #{EVENT_FRAGMENT}
          }
        }
      }
    })['data']['venue']
  end

  def self.country code
    AtlasSchema.execute(%{
      query {
        country(code: "#{code}") {
          bounds
        }
      }
    })['data']['country']
  end

end