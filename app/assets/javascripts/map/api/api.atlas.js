/* global Util */
/* exported AtlasAPI */

class AtlasAPI {

  constructor(api_endpoint) {
    if (api_endpoint.indexOf('?') == -1) {
      this.api_endpoint = `${api_endpoint}?`
    } else {
      this.api_endpoint = `${api_endpoint}&`
    }
    
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

  getClosest(parameters, callback) {
    console.log('[AtlasAPI]', 'getting closest', parameters) // eslint-disable-line no-console
    parameters = Object.keys(parameters).map(key => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(parameters[key])
    }).join('&')

    Util.getURL(`/map/closest?${parameters}`, xhttp => {
      const response = JSON.parse(xhttp.response)
      console.log('[AtlasAPI]', 'received', response) // eslint-disable-line no-console
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

}
