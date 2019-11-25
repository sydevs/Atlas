/* globals GeoSearch */
/* exported GeoSearchAPI */

class GeoSearchAPI {

  constructor() {
    this.service = new GeoSearch.OpenStreetMapProvider()
  }

  query(text, callback) {
    this.service.search({ query: text }).then((response, status) => {
      const results = this.parseServiceResponse(response)
      callback(results)
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
