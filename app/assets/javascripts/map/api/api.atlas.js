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
          descriptionHtml
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
            recurrenceCount
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
          areaId
          location {
            id
            type
            label
            latitude
            longitude
            radius
            onlineEventIds
            offlineEventIds
            directionsUrl
            parentId
            parentType
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
          subtitle
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
            subtitle
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
    let models
    this.fetchGeojson = this.graph.query(`($online: Boolean, $languageCode: String) {
      geojson(online: $online, languageCode: $languageCode, locale: "${locale}") { ...geojson }
    }`)

    models = [AtlasEvent]
    models.forEach(Model => {
      this[`fetchAll${Model.LABELS}`] = this.graph.query(`($ids: [ID!]) {
        ${Model.KEYS}(ids: $ids, locale: "${locale}") { ...${Model.KEY} }
      }`)
    })

    models = [AtlasCountry, AtlasRegion, AtlasArea, AtlasVenue, AtlasEvent]
    models.forEach(Model => {
      this[`fetch${Model.LABEL}`] = this.graph.query(`(@autodeclare) {
        ${Model.KEY}(id: $id, locale: "${locale}") { ...${Model.KEY} }
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
          area {
            id
            label
            subtitle
            latitude
            longitude
            radius
          }
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
