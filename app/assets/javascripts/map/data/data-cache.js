/* exported DataCache */

/* global AtlasAPI, Util */

let LAST_REQUEST_ID = -1

class DataCache {

  #cache
  #atlas
  #requests
  #debug = false
  #models = { AtlasCountry, AtlasRegion, AtlasArea, AtlasVenue, AtlasEvent }

  constructor(endpoint, locale) {
    this.#atlas = new AtlasAPI(endpoint, locale)
    this.#requests = {}
    this.#cache = {
      geojsons: {},
      lists: {},
      sortedLists: {},
      closestVenue: null,
      closestfetchVenue: null,
    }

    Object.values(this.#models).forEach(Model => {
      this.#cache[Model.key] = {}
    })
  }

  getGeojson(layer) {
    if (layer in this.#cache.geojsons) {
      return Promise.resolve(this.#cache.geojsons[layer])
    } else {
      if (this.#debug) console.log('[Data]', 'getting geojson', layer) // eslint-disable-line no-console
      return this.#atlas.fetchGeojson({
        online: layer == AtlasEvent.LAYER.online,
        languageCode: (layer == AtlasEvent.LAYER.online ? AtlasApp.config.locale : null),
      }).then(data => {
        this.#cache.geojsons[layer] = data.geojson
        return data.geojson
      })
    }
  }

  getEvents(ids) {
    let uncachedEventIds = ids.filter(id => !(id in this.#cache.event))
    let fetchEvents

    if (uncachedEventIds.length > 0) {
      if (this.#debug) console.log('[Data]', 'getting events', ids, '(' + (1 - uncachedEventIds.length / ids.length) * 100 + '% cached)') // eslint-disable-line no-console
      fetchEvents = this.#atlas.fetchEvents({ ids: uncachedEventIds }).then(response => {
        response.events.forEach(event => {
          this.#cache.event[event.id] = new AtlasEvent(event)
        })
      })
    } else {
      fetchEvents = Promise.resolve()
    }

    return fetchEvents.then(() => {
      return ids.map(id => this.#cache.event[id]).filter(Boolean)
    })
  }

  getAllOnlineEvents() {
    if ('online' in this.#cache.lists) {
      return Promise.resolve(this.#cache.lists['online'])
    } else {
      return this.#atlas.fetchOnlineList().then(response => {
        this.#cache.lists['online'] = response.events.map(event => {
          event = new AtlasEvent(event)
          this.#cache.event[event.id] = event
          return event
        })

        return this.#cache.lists['online']
      })
    }
  }

  getList(filter = 'all', ids = null) {
    let fetchList
    const request = this.registerRequest('list')

    if (ids == null || ids.length < 1)
      filter = 'online'

    if (filter in this.#cache.sortedLists) {
      return Promise.resolve(this.#cache.sortedLists[filter])
    } else if (filter in this.#cache.lists) {
      fetchList = Promise.resolve(this.#cache.lists[filter])
    } else {
      let lists = []
      if (filter !== 'online')
        lists.push(this.getEvents(ids))

      if (filter !== 'offline')
        lists.push(this.getAllOnlineEvents(ids))

      fetchList = Promise.all(lists).then(values => values.flat())
    }

    return fetchList.then(list => {
      if (this.isRequestExpired(request)) {
        return this.#cache.sortedLists[filter]
      }

      this.#cache.lists[filter] = list
      list = list.sort((a, b) => a.order - b.order)
      this.#cache.sortedLists[filter] = list
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
    
    if (this.#debug) console.log('[Data]', 'getting closest venue', params) // eslint-disable-line no-console
    return this.#atlas.fetchClosestVenue(params).then(data => {
      this.#cache.closestfetchVenue = params
      this.#cache.closestVenue = data.closestVenue
      return data.closestVenue || {}
    })
  }

  getRecord(Model, id) {
    if (!Model || !id) return Promise.resolve(null)

    if (id in this.#cache[Model.key]) {
      return Promise.resolve(this.#cache[Model.key][id])
    } else {
      const fetchRecord = this.#atlas[`fetch${Model.label}`]

      if (!fetchRecord) return Promise.resolve(null)
      if (this.#debug) console.log('[Data]', 'getting', Model.key, id) // eslint-disable-line no-console
      
      return fetchRecord({ id: id }).then(data => {
        const record = new Model(data[Model.key])
        this.#cache[Model.key][id] = record
        return record
      })
    }
  }

  // MUTATION REQUESTS

  createRegistration(params) {
    if (this.#debug) console.log('[Data]', 'creating registration', params) // eslint-disable-line no-console
    params.locale = AtlasApp.config.locale
    return this.#atlas.sendRegistration({
      'input!CreateRegistrationInput': params
    }).then(data => data.createRegistration)
  }

  // HELPER METHODS

  parse(data) {
    ['onlineEventIds', 'offlineEventIds'].forEach(field => {
      if (typeof data[field] === 'string') {
        data[field] = JSON.parse(data[field])
      }
    })

    return new this.#models[`Atlas${data.type}`](data)
  }

  setCache(key, object) {
    this.#cache[key][object.id] = object
  }

  clearCache(key, id = null) {
    if (id !== null) {
      delete this.#cache[key][id]
    } else {
      this.#cache[key] = {}
    }
  }

  registerRequest(key) {
    LAST_REQUEST_ID += 1
    this.#requests[key] = LAST_REQUEST_ID
    return { key: key, id: LAST_REQUEST_ID }
  }

  isRequestExpired(request) {
    return this.#requests[request.key] > request.id
  }

}