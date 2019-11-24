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
    for (let i = 0; i < Math.min(data.length, 8); i++) {
      results.push({
        label: data[i].label,
        latitude: data[i].y,
        longitude: data[i].x,
      })
    }

    return results
  }

}
