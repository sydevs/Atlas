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
          phoneName
          phoneNumber
          online
          onlineUrl
          registrationMode
          registrationUrl
          registrationEndTime
          registrationLimit
          registrationCount
          path
          timing {
            duration
            timeZone
            recurrence
          }
          firstOccurrence
          lastOccurrence
          upcomingOccurrences
          images {
            url
            thumbnailUrl
          }
          location {
            id
            directionsUrl
          }
        }`,
        eventWithLocation: `on Event {
          id
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
          }
          firstOccurrence
          lastOccurrence
          upcomingOccurrences
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
        location: `on Location {
          id
          label
          latitude
          longitude
          directionsUrl
          events {
            ...event
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
              ...location
            }
          }
        }`
      }
    })

    this.geojsonQuery = this.graph.query(`(@autodeclare) {
      geojson(online: $online, locale: "${window.locale}") { ...geojson }
    }`)

    this.eventsQuery = this.graph.query(`($online: Boolean) {
      events(online: $online, locale: "${window.locale}") { ...event }
    }`)

    this.searchEventsQuery = this.graph.query(`
      query ($online: Boolean, $recurrence: String, $languageCode: String, locale: "${window.locale}") {
        events(online: $online, recurrence: $recurrence, languageCode: $languageCode) {
          ...eventWithVenue
        }
      }
    `)

    this.closestVenueQuery = this.graph.query(`
      query ($latitude: Float!, $longitude: Float!) {
        closestVenue(latitude: $latitude, longitude: $longitude, locale: "${window.locale}") {
          id
          label
          city
          countryCode
          latitude
          longitude
        }
      }
    `)

    this.eventQuery = this.graph.query(`(@autodeclare) {
      event(id: $id, locale: "${window.locale}") { ...event }
    }`)

    this.venueQuery = this.graph.query(`(@autodeclare) {
      venue(id: $id, locale: "${window.locale}") { ...venue }
    }`)

    this.registrationQuery = this.graph.mutate(`(@autodeclare) {
      createRegistration(input: $input) {
        status
        message
      }
    }`)
  }

  async getGeojson(mode, callback) {
    const data = await this.geojsonQuery({ online: mode == 'online' })
    callback(data.geojson)
  }

  async getVenue(id, callback) {
    console.log('[AtlasAPI]', 'getting venue', id) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('venue', id, 100)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const data = await this.venueQuery(id)
    this.setCache('venue', id, data.venue)
    console.log('[AtlasAPI]', 'received', data) // eslint-disable-line no-console
    callback(data.venue)
  }

  async getEvent(id, callback) {
    console.log('[AtlasAPI]', 'getting event', id) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('event', id, 100)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const data = await this.eventQuery({ id: id })
    this.setCache('event', id, data.event)
    console.log('[AtlasAPI]', 'received', data) // eslint-disable-line no-console
    callback(data.event)
  }

  async getEvents(params, callback) {
    const mode = params.online ? 'online' : 'offline'
    console.log('[AtlasAPI]', 'getting', mode, 'events', params.coordinates) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('events', mode, params.coordinates, 100)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const data = await this.eventsQuery({ online: params.online })
    this.setCache('events', params, data.events)
    console.log('[AtlasAPI]', 'received', data) // eslint-disable-line no-console
    callback(data.events)
  }

  async searchEvents(params, callback) {
    console.log('[AtlasAPI]', 'searching events', params) // eslint-disable-line no-console
    const data = await this.searchEventsQuery(params)
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
    parameters.locale = window.locale
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
