/* global Util, graphql */
/* exported AtlasAPI */

class AtlasAPI {

  constructor() {
    console.log('loading AtlasAPI.js') // eslint-disable-line no-console
    this.prepareGraphQL()
    this.prepareQueries()
    this.prepareMutators()
  }

  prepareGraphQL() {
    this.graph = graphql('/api/graphql', {
      fragments: {
        event: `on Event {
          id
          layer
          label
          description
          category
          address
          languageCode
          phoneName
          phoneNumber
          online
          onlineUrl
          registrationMode
          registrationUrl
          path
          timing {
            duration
            timeZone
            firstDate
            lastDate
            upcomingDates
          }
          images {
            url
            thumbnailUrl
          }
          location {
            id
            label
            latitude
            longitude
            directionsUrl
          }
        }`,
        venue: `on Venue {
          id
          label
          latitude
          longitude
          eventIds
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
          bounds
          onlineEventIds
          offlineEventIds
          areas {
            id
            label
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
            label
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
              label
              latitude
              longitude
              radius
              eventIds
            }
          }
        }`
      }
    })
  }

  prepareQueries() {
    this.fetchGeojson = this.graph.query(`($online: Boolean, $languageCode: String) {
      geojson(online: $online, languageCode: $languageCode, locale: "${window.locale}") { ...geojson }
    }`)

    this.fetchEvents = this.graph.query(`($ids: [ID!]) {
      events(ids: $ids, locale: "${window.locale}") { ...event }
    }`)

    const models = [AtlasCountry, AtlasRegion, AtlasArea, AtlasVenue, AtlasEvent]
    models.forEach(Model => {
      this[`fetch${Model.label}`] = this.graph.query(`(@autodeclare) {
        ${Model.key}(id: $id, locale: "${window.locale}") { ...${Model.key} }
      }`)
    })

    this.fetchOnlineList = this.graph.query(`(@autodeclare) {
      events(online: true, languageCode: "${window.locale}", locale: "${window.locale}") { ...event }
    }`)

    this.fetchClosestVenue = this.graph.query(`
      query ($latitude: Float!, $longitude: Float!) {
        closestVenue(latitude: $latitude, longitude: $longitude, locale: "${window.locale}") {
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
      }
    }`)
  }

}
