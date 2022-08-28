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

    this.fetchEvent = this.graph.query(`(@autodeclare) {
      event(id: $id, locale: "${window.locale}") { ...event }
    }`)

    this.fetchVenue = this.graph.query(`(@autodeclare) {
      venue(id: $id, locale: "${window.locale}") { ...venue }
    }`)

    this.fetchArea = this.graph.query(`(@autodeclare) {
      area(id: $id, locale: "${window.locale}") { ...area }
    }`)

    this.searchEvents = this.graph.query(`
      query ($online: Boolean, $recurrence: String, $languageCode: String, locale: "${window.locale}") {
        events(online: $online, recurrence: $recurrence, languageCode: $languageCode) {
          ...event
        }
      }
    `)

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
