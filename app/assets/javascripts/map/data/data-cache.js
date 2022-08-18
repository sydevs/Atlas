/* exported DataCache */

/* global AtlasAPI */

class DataCache {
  
  #cache
  #atlas

  constructor() {
    this.#atlas = new AtlasAPI()
    this.#cache = {
      events: {},
      venues: {},
      areas: {},
      geojsons: {},
      lists: {},
      sortedLists: {},
      closestVenue: null,
      closestfetchVenue: null,
    }
  }

  searchEvents(params) {
    console.log('[Data]', 'searching events', params) // eslint-disable-line no-console
    return this.#atlas.searchEvents(params).then(data => data.events)
  }

  getGeojson(layer) {
    if (layer in this.#cache.geojsons) {
      return Promise.resolve(this.#cache.geojsons[layer])
    } else {
      console.log('[Data]', 'getting geojson', layer) // eslint-disable-line no-console
      return this.#atlas.fetchGeojson({
        online: layer == 'online',
        languageCode: (layer == 'online' ? window.locale : null),
      }).then(data => {
        this.#cache.geojsons[layer] = data.geojson
        return data.geojson
      })
    }
  }

  getArea(id) {
    if (id in this.#cache.areas) {
      return Promise.resolve(this.#cache.areas[id])
    } else {
      console.log('[Data]', 'getting area', id) // eslint-disable-line no-console
      return this.#atlas.fetchArea({ id: id }).then(data => {
        const area = new AtlasArea(data.area)
        this.#cache.areas[id] = area
        return area
      })
    }
  }

  getVenue(id) {
    if (id in this.#cache.venues) {
      return Promise.resolve(this.#cache.venues[id])
    } else {
      console.log('[Data]', 'getting venue', id) // eslint-disable-line no-console
      return this.#atlas.fetchVenue({ id: id }).then(data => {
        const venue = new AtlasVenue(data.venue)
        this.#cache.venues[id] = venue
        return venue
      })
    }
  }

  getEvent(id) {
    if (id in this.#cache.events) {
      return Promise.resolve(this.#cache.events[id])
    } else {
      console.log('[Data]', 'getting event', id) // eslint-disable-line no-console
      return this.#atlas.fetchEvent({ id: id }).then(data => {
        const event = new AtlasEvent(data.event)
        this.#cache.events[id] = event
        return event
      })
    }
  }

  getEvents(ids) {
    let uncachedEventIds = ids.filter(id => !(id in this.#cache.events))
    let fetchEvents

    if (uncachedEventIds.length > 0) {
      console.log('[Data]', 'getting events', ids, '(' + (1 - uncachedEventIds.length / ids.length) * 100 + '% cached)') // eslint-disable-line no-console
      fetchEvents = this.#atlas.fetchEvents({ ids: uncachedEventIds }).then(response => {
        response.events.forEach(event => {
          this.#cache.events[event.id] = new AtlasEvent(event)
        })
      })
    } else {
      fetchEvents = Promise.resolve()
    }

    return fetchEvents.then(() => {
      return ids.map(id => this.#cache.events[id]).filter(Boolean)
    })
  }

  getList(layer, ids = null) {
    let fetchList

    if (layer in this.#cache.sortedLists) {
      return Promise.resolve(this.#cache.sortedLists[layer])
    } else if (layer in this.#cache.lists) {
      fetchList = Promise.resolve(this.#cache.lists[layer])
    } else if (layer == 'online') {
      console.log('[Data]', 'getting list', layer) // eslint-disable-line no-console
      fetchList = this.#atlas.fetchOnlineList().then(response => {
        return response.events.map(event => {
          event = new AtlasEvent(event)
          this.#cache.events[event.id] = event
          return event
        })
      })
    } else {
      console.log('[Data]', 'getting list', layer) // eslint-disable-line no-console
      fetchList = this.getEvents(ids)
    }

    return fetchList.then(list => {
      this.#cache.lists[layer] = list
      list = list.sort((a, b) => a.order - b.order)
      this.#cache.sortedLists[layer] = list
      return list
    })
  }

  getClosestVenue(params) {
    let cache = this.#cache.closestVenue
    let cacheQuery = this.#cache.closestfetchVenue
    if (cache && cacheQuery) {
      const distance = Util.distance(params, cacheQuery)
      if (distance <= 0.5) {
        return Promise.resolve(cache)
      }
    }
    
    console.log('[Data]', 'getting closest venue', params) // eslint-disable-line no-console
    return this.#atlas.fetchClosestVenue(params).then(data => {
      this.#cache.closestfetchVenue = params
      this.#cache.closestVenue = data.closestVenue
      return data.closestVenue || {}
    })
  }

  // MUTATION REQUESTS

  createRegistration(params) {
    console.log('[Data]', 'creating registration', params) // eslint-disable-line no-console
    params.locale = window.locale
    return this.#atlas.sendRegistration({
      'input!CreateRegistrationInput': params
    }).then(data => data.createRegistration)
  }

  // HELPER METHODS

  getRecord(model, id) {
    if (model == 'area') {
      return this.getArea(id)
    } else if (model == 'venue') {
      return this.getVenue(id)
    } else if (model == 'event') {
      return this.getEvent(id)
    } else {
      return Promise.resolve(null)
    }
  }

  setCache(key, object) {
    this.#cache[key][object.id] = object
  }

  clearCache(key) {
    this.#cache[key] = {}
  }

}