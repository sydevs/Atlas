/* global Util, graphql */
/* exported AtlasAPI */

class AtlasAPI {

  constructor() {
    this.prepareGraphQL()
    this.cache = {}
    console.log('loading AtlasAPI.js') // eslint-disable-line no-console
  }

  prepareGraphQL() {
    this.graph = graphql('/api/graphql', {
      fragments: {
        event: `on Event {
          id
          label
          description
          category
          address
          languageCode
          online
          onlineUrl
          registrationMode
          registrationUrl
          timing {
            recurrence
            startDate
            endDate
            startTime
            endTime
          }
          images {
            url
          }
        }`,
        venue: `on Venue {
          id
          label
          latitude
          longitude
          directionsUrl
          events {
            ...event
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
              ...venue
            }
          }
        }`
      }
    })

    this.geojsonQuery = this.graph.query(`{
      geojson { ...geojson }
    }`)

    this.onlineEventsQuery = this.graph.query(`{
      events(online: true) { ...event }
    }`)

    this.closestVenueQuery = this.graph.query(`(@autodeclare) {
      closestVenue(latitude: $latitude, longitude: $longitude) {
        id
        label
        city
        countryCode
        latitude
        longitude
      }
    }`)

    this.registrationQuery = this.graph.mutate(`(@autodeclare) {
      createRegistration(input: $input) {
        status
        message
      }
    }`)
  }

  async getGeojson(callback) {
    const data = await this.geojsonQuery()
    callback(data.geojson)
  }

  async getOnlineEvents(coordinates, callback) {
    console.log('[AtlasAPI]', 'getting online events', coordinates) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('onlineEvents', coordinates, 100)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const data = await this.onlineEventsQuery(coordinates)
    this.setCache('onlineEvents', coordinates, data.events)
    console.log('[AtlasAPI]', 'received', data) // eslint-disable-line no-console
    callback(data.events)
  }

  async getClosestVenue(coordinates, callback) {
    console.log('[AtlasAPI]', 'getting closest venue', coordinates) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('closestVenue', coordinates, 0.2)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const data = await this.closestVenueQuery(coordinates)
    this.setCache('closestVenue', coordinates, data.closestVenue)
    console.log('[AtlasAPI]', 'received', data) // eslint-disable-line no-console
    callback(data.closestVenue)
  }

  async createRegistration(parameters, callback) {
    console.log('[AtlasAPI]', 'creating registration', parameters) // eslint-disable-line no-console
    const data = await this.registrationQuery({
      'input!CreateRegistrationInput': parameters
    })

    console.log('[AtlasAPI]', 'received', data) // eslint-disable-line no-console
    callback(data.createRegistration)
  }

  setCache(key, parameters, response) {
    this.cache[key] = {
      latitude: parameters.latitude,
      longitude: parameters.longitude,
      response: response
    }
  }

  checkCache(key, params, allowedDistance) {
    if (!this.cache[key]) return null
    
    const cache = this.cache[key]
    const distance = Util.distance(params.latitude, params.longitude, cache.latitude, cache.longitude)
    return distance <= allowedDistance ? cache.response : null
  }

}
