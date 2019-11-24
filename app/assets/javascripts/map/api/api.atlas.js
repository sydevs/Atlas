/* global Util */
/* exported AtlasAPI */

class AtlasAPI {

  constructor() {
    console.log('loading AtlasAPI.js') // eslint-disable-line no-console
  }

  query(parameters, callback) {
    parameters = Object.keys(parameters).map(key => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(parameters[key])
    }).join('&')

    Util.getURL(`/api/events.json?${parameters}`, xhttp => {
      AtlasAPI.events = JSON.parse(xhttp.response)
      callback(AtlasAPI.events)
    })
  }

}
