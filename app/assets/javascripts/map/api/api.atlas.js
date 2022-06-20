/* global Util, graphql */
/* exported AtlasAPI */

class AtlasAPI {

  constructor() {
    this.prepareGraphQL()
    this.cache = {
      events: {},
      closestVenue: null,
    }
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
        venue: `on Venue {
          id
          label
          latitude
          longitude
          eventIds
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
              eventIds
            }
          }
        }`
      }
    })

    this.geojsonQuery = this.graph.query(`(@autodeclare) {
      geojson(online: $online, locale: "${window.locale}") { ...geojson }
    }`)

    this.eventQuery = this.graph.query(`(@autodeclare) {
      event(id: $id, locale: "${window.locale}") { ...event }
    }`)

    this.eventsQuery = this.graph.query(`($ids: [ID!]) {
      events(ids: $ids, locale: "${window.locale}") { ...event }
    }`)

    this.searchEventsQuery = this.graph.query(`
      query ($online: Boolean, $recurrence: String, $languageCode: String, locale: "${window.locale}") {
        events(online: $online, recurrence: $recurrence, languageCode: $languageCode) {
          ...event
        }
      }
    `)

    this.venueQuery = this.graph.query(`(@autodeclare) {
      venue(id: $id, locale: "${window.locale}") { ...venue }
    }`)

    this.closestVenueQuery = this.graph.query(`
      query ($latitude: Float!, $longitude: Float!) {
        closestVenue(latitude: $latitude, longitude: $longitude, locale: "${window.locale}") {
          id
          label
          latitude
          longitude
        }
      }
    `)

    this.registrationQuery = this.graph.mutate(`(@autodeclare) {
      createRegistration(input: $input) {
        status
        message
      }
    }`)
  }

  // NON-CACHED REQUESTS

  getGeojson(mode) {
    console.log('[AtlasAPI]', 'getting geojson', mode) // eslint-disable-line no-console
    return this.geojsonQuery({ online: mode == 'online' }).then(data => data.geojson)
  }

  async getVenue(id) {
    console.log('[AtlasAPI]', 'getting venue', id) // eslint-disable-line no-console
    return this.venueQuery({ id: id }).then(data => data.venue).then(venue => {
      console.log('[AtlasAPI]', 'got venue', venue) // eslint-disable-line no-console
      return venue
    })
  }

  searchEvents(params) {
    console.log('[AtlasAPI]', 'searching events', params) // eslint-disable-line no-console
    return this.searchEventsQuery(params).then(data => data.events)
  }

  // CACHED REQUESTS

  async getEvent(id) {
    console.log('[AtlasAPI]', 'getting event', id) // eslint-disable-line no-console
    if (id in this.cache.events) {
      return this.cache.events[id]
    } else {
      return await this.eventQuery({ id: id }).then(data => data.event)
    }
  }

  async getEvents(ids) {
    let uncachedEventIds = ids.filter(id => !(id in this.cache.events))
    console.log('[AtlasAPI]', 'getting events', ids, '(' + (1 - uncachedEventIds.length / ids.length) * 100 + '% cached)') // eslint-disable-line no-console

    if (uncachedEventIds.length > 0) {
      const data = await this.eventsQuery({ ids: uncachedEventIds })
      data.events.forEach(event => {
        this.cache.events[event.id] = event
      })
    }

    return ids.map(id => this.cache.events[id])
  }

  async getClosestVenue(params) {
    console.log('[AtlasAPI]', 'getting closest venue', params) // eslint-disable-line no-console
    
    let result = null
    let cache = this.cache.closestVenue
    if (cache) {
      const distance = Util.distance(params.latitude, params.longitude, cache.latitude, cache.longitude)
      if (distance <= 0.2) {
        result = cache
      }
    }

    if (!result) {
      const data = await this.closestVenueQuery(params)
      result = data.venue
    }

    return result
  }

  // MUTATION REQUESTS

  createRegistration(params) {
    params.locale = window.locale
    console.log('[AtlasAPI]', 'creating registration', params) // eslint-disable-line no-console
    return this.registrationQuery({
      'input!CreateRegistrationInput': params
    })
  }

  // CACHE FUNCTIONS

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
