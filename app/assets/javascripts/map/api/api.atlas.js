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
      AtlasAPI.events = JSON.parse(xhttp.response)
      callback(AtlasAPI.events)
    })
  }

}
