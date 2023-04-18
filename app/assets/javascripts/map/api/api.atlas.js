/* global Util, graphql */
/* exported AtlasAPI */

class AtlasAPI {

  constructor(endpoint, locale) {
    console.log('loading AtlasAPI.js') // eslint-disable-line no-console
    this.prepareGraphQL(endpoint)
    this.prepareQueries(locale)
    this.prepareMutators()
  }

  prepareGraphQL(endpoint) {
    this.graph = graphql(endpoint, {
      fragments: {
        event: `on Event {
          id
          url
          layer
          label
          description
          category
          address
          languageCode
          online
          onlineUrl
          path
          registrationMode
          registrationUrl
          registrationQuestions {
            slug
            title
          }
          timing {
            duration
            timeZone
            firstDate
            lastDate
            upcomingDates
            recurrence
          }
          contact {
            phoneName
            phoneNumber
            emailName
            emailAddress
            meetup
            facebook
          }
          images {
            url
            thumbnailUrl
          }
          location {
            id
            type
            label
            latitude
            longitude
            onlineEventIds
            offlineEventIds
            parentId
            parentType
            directionsUrl
          }
        }`,
        venue: `on Venue {
          id
          label
          latitude
          longitude
          offlineEventIds
          parentId
        }`,
        area: `on Area {
          id
          label
          latitude
          longitude
          radius
          onlineEventIds
          offlineEventIds
          region {
            id
          }
        }`,
        region: `on Region {
          id
          label
          onlineEventBounds
          offlineEventBounds
          onlineEventIds
          offlineEventIds
          areas {
            id
            name
            onlineEventIds
            offlineEventIds
          }
          country {
            id
          }
        }`,
        country: `on Country {
          id
          label
          bounds
          onlineEventIds
          offlineEventIds
          regions {
            id
            name
            onlineEventIds
            offlineEventIds
          }
        }`,
        geojson: `on Geojson {
          type
          features {
            type
            id
            geometry {
              type
              coordinates
            }
            properties {
              id
              type
              label
              latitude
              longitude
              radius
              onlineEventIds
              offlineEventIds
              parentId
              parentType
            }
          }
        }`
      }
    })
  }

  prepareQueries(locale) {
    this.fetchGeojson = this.graph.query(`($online: Boolean, $languageCode: String) {
      geojson(online: $online, languageCode: $languageCode, locale: "${locale}") { ...geojson }
    }`)

    this.fetchEvents = this.graph.query(`($ids: [ID!]) {
      events(ids: $ids, locale: "${locale}") { ...event }
    }`)

    const models = [AtlasCountry, AtlasRegion, AtlasArea, AtlasVenue, AtlasEvent]
    models.forEach(Model => {
      this[`fetch${Model.label}`] = this.graph.query(`(@autodeclare) {
        ${Model.key}(id: $id, locale: "${locale}") { ...${Model.key} }
      }`)
    })

    this.fetchOnlineList = this.graph.query(`(@autodeclare) {
      events(online: true, languageCode: "${locale}", locale: "${locale}") { ...event }
    }`)

    this.fetchClosestVenue = this.graph.query(`
      query ($latitude: Float!, $longitude: Float!) {
        closestVenue(latitude: $latitude, longitude: $longitude, locale: "${locale}") {
          id
          label
          latitude
          longitude
        }
      }
    `)
  }

  prepareMutators() {
    this.sendRegistration = this.graph.mutate(`(@autodeclare) {
      createRegistration(input: $input) {
        status
        message
        registration {
          id
        }
      }
    }`)
  }

}
