/* global Util */
/* exported AtlasAPI */

class AtlasAPI {

  constructor(api_endpoint) {
    this.api_endpoint = api_endpoint
    console.log('loading AtlasAPI.js') // eslint-disable-line no-console
  }

  query(parameters, callback) {
    parameters = Object.keys(parameters).map(key => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(parameters[key])
    }).join('&')

    Util.getURL(`${this.api_endpoint}?${parameters}`, xhttp => {
      console.log('[AtlasAPI]', xhttp.response) // eslint-disable-line no-console
      callback(JSON.parse(xhttp.response))
    })
  }

}
