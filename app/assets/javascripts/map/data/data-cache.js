/* exported DataCache */

/* global AtlasAPI, Util */

class DataCache {

  #cache
  #atlas
  #debug = true
  #models = [AtlasCountry, AtlasRegion, AtlasArea, AtlasVenue, AtlasEvent]

  constructor(endpoint, locale) {
    this.#atlas = new AtlasAPI(endpoint, locale)
    this.#cache = {
      geojsons: {},
      lists: {},
      sortedLists: {},
      closestVenue: null,
      closestfetchVenue: null,
    }

    this.#models.forEach(Model => {
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

  getList(layer, ids = null) {
    let fetchList

    if (layer in this.#cache.sortedLists) {
      return Promise.resolve(this.#cache.sortedLists[layer])
    } else if (layer in this.#cache.lists) {
      fetchList = Promise.resolve(this.#cache.lists[layer])
    } else if (layer == AtlasEvent.LAYER.online) {
      if (this.#debug) console.log('[Data]', 'getting list', layer) // eslint-disable-line no-console
      fetchList = this.#atlas.fetchOnlineList().then(response => {
        return response.events.map(event => {
          event = new AtlasEvent(event)
          this.#cache.event[event.id] = event
          return event
        })
      })
    } else {
      if (this.#debug) console.log('[Data]', 'getting list', layer) // eslint-disable-line no-console
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

  setCache(key, object) {
    this.#cache[key][object.id] = object
  }

  clearCache(key) {
    this.#cache[key] = {}
  }

}