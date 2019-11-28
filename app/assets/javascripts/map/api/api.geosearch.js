/* globals GeoSearch */
/* exported GeoSearchAPI */

class GeoSearchAPI {

  constructor() {
    this.service = new GeoSearch.OpenStreetMapProvider()
  }

  query(text, callback) {
    this.latestQuery = text
    this.waiting = true

    this.service.search({ query: text }).then(response => {
      if (text == this.latestQuery) {
        console.log('[GeoSearchAPI]', text, response) // eslint-disable-line no-console
        this.waiting = false
        callback(this.parseServiceResponse(response))
      } else {
        console.log('[GeoSearchAPI]', 'Ignored expired request:', text) // eslint-disable-line no-console
      }
    })
  }

  parseServiceResponse(data) {
    const results = []
    
    // Showing only 8 results for now, potentially increase/descrease the number
    for (let i = 0; i < data.length; i++) {
      const dat = data[i]

      if (dat.raw.class == 'place') {
        results.push({
          label: dat.label,
          latitude: dat.y,
          longitude: dat.x,
        })
      }
      
      if (results.length >= 8) {
        break
      }
    }

    return results
  }

}
