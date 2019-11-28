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

    Util.getURL(`${this.api_endpoint}${parameters}`, xhttp => {
      const response = JSON.parse(xhttp.response)
      console.log('[AtlasAPI]', response) // eslint-disable-line no-console
      callback(response)
    })
  }

}
