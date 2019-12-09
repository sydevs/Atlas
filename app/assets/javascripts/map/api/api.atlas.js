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
    parameters = Object.keys(parameters).map(key => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(parameters[key])
    }).join('&')

    const query = `${this.api_endpoint}${parameters}`
    Util.getURL(query, xhttp => {
      const response = JSON.parse(xhttp.response)
      console.log('[AtlasAPI]', response, query) // eslint-disable-line no-console
      callback(response)
    })
  }

  register(form, callback) {
    Util.postForm('/map/registrations', form, callback)
  }

}
