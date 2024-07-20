/* exported DataCache */

/* global AtlasAPI, Util */

let LAST_REQUEST_ID = -1

class DataCache {

  #cache
  #atlas
  #requests
  #debug = true
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
      this[Model.KEYS] = new AtlasTable(this.#atlas, Model)
    })
  }

  getGeojson(layer) {
    if (layer in this.#cache.geojsons) {
      return DataRequest.resolve(this.#cache.geojsons[layer])
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

  getRecord(Model, id) {
    if (!Model || !id) throw `Invalid model or id (${Model} ${id})`
    return this[Model.KEYS].fetch(id)
  }

  getRecords(Model, ids) {
    if (!Model || !ids) throw `Invalid model or id (${Model} ${ids})`
    return this[Model.KEYS].fetchAll(ids)
  }

  getAllOnlineEvents() {
    if ('online' in this.#cache.lists) {
      return DataRequest.resolve(this.#cache.lists['online'])
    } else {
      return this.#atlas.fetchOnlineList().then(response => {
        this.#cache.lists['online'] = this.events.cache(response.events)
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
      return DataRequest.resolve(this.#cache.sortedLists[filter])
    } else if (filter in this.#cache.lists) {
      fetchList = DataRequest.resolve(this.#cache.lists[filter])
    } else {
      let lists = []
      if (filter !== 'online')
        lists.push(this.getRecords(AtlasEvent, ids))

      if (filter !== 'offline')
        lists.push(this.getAllOnlineEvents(ids))

      fetchList = DataRequest.all(lists).then(values => values.flat())
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
        return DataRequest.resolve(cache)
      }
    }
    
    if (this.#debug) console.log('[Data]', 'getting closest venue', params) // eslint-disable-line no-console
    return this.#atlas.fetchClosestVenue(params).then(data => {
      this.#cache.closestfetchVenue = params
      this.#cache.closestVenue = data.closestVenue
      return data.closestVenue || {}
    })
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
    if (!(key in this.#requests)) {
      this.#requests[key] = -1
    }
    
    LAST_REQUEST_ID += 1
    return { key: key, id: LAST_REQUEST_ID }
  }

  isRequestExpired(request) {
    if (this.#requests[request.key] < request.id) {
      this.#requests[request.key] = request.id
      return false
    }

    return true
  }

}