/* global Util */
/* exported AtlasAPI */

class AtlasAPI {

  constructor(api_endpoint) {
    if (api_endpoint.indexOf('?') == -1) {
      this.api_endpoint = `${api_endpoint}?`
    } else {
      this.api_endpoint = `${api_endpoint}&`
    }
    
    this.cache = {}
    console.log('loading AtlasAPI.js') // eslint-disable-line no-console
  }

  query(parameters, callback) {
    console.log('[AtlasAPI]', 'sending', parameters) // eslint-disable-line no-console
    parameters = Object.keys(parameters).map(key => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(parameters[key])
    }).join('&')

    const query = `${this.api_endpoint}${parameters}`
    Util.getURL(query, xhttp => {
      const response = JSON.parse(xhttp.response)
      console.log('[AtlasAPI]', 'received', response, query) // eslint-disable-line no-console
      callback(response)
    })
  }

  register(form, callback) {
    Util.postForm('/map/registrations', form, event => {
      const response = JSON.parse(event.target.response)
      console.log('[AtlasAPI]', 'received', response) // eslint-disable-line no-console
      response.message = response.message.replace('%{date}', new Date(response.date).toLocaleString(undefined, {
        year: 'numeric', month: 'short', day: 'numeric',
        hour: 'numeric', minute: 'numeric'
      }))

      callback(response)
    })
  }

  getClosestVenue(options, callback) {
    console.log('[AtlasAPI]', 'getting closest venue', options) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('closestVenue', options, 0.2)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const parameters = this.encodeParameters(options)
    Util.getURL(`/map/closest?${parameters}`, xhttp => {
      const response = JSON.parse(xhttp.response)
      this.setCache('closestVenue', options, response)
      console.log('[AtlasAPI]', 'received', response) // eslint-disable-line no-console
      callback(response)
    })
  }

  getOnlineEvents(options, callback) {
    console.log('[AtlasAPI]', 'getting online events', options) // eslint-disable-line no-console

    const cacheResponse = this.checkCache('onlineEvents', options, 100)
    if (cacheResponse) {
      console.log('[AtlasAPI]', 'cache hit', cacheResponse) // eslint-disable-line no-console
      callback(cacheResponse)
      return
    }

    const parameters = this.encodeParameters(options)
    Util.getURL(`/map/online?${parameters}`, xhttp => {
      const response = JSON.parse(xhttp.response)
      this.setCache('onlineEvents', options, response)
      console.log('[AtlasAPI]', 'received', response) // eslint-disable-line no-console
      callback(response)
    })
  }

  encodeParameters(parameters) {
    return Object.keys(parameters).map(key => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(parameters[key])
    }).join('&')
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
    const distance = Util.distance(params.latitude, params.longitude, cache.latitude, cache.longitude, 'K')
    return distance <= allowedDistance ? cache.response : null
  }

}
