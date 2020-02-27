/* globals */
/* exported GeoSearchAPI */

class GeoSearchAPI {

  constructor(key, country) {
    this.config = {
      access_token: key,
      format: 'json',
      autocomplete: true,
      language: document.documentElement.lang,
      types: 'country,region,postcode,district,place,locality,neighborhood,address',
    }

    if (country) {
      this.config.country = country
      this.config.typs = 'region,postcode,district,place,locality,neighborhood,address'
    }

    this.config = Object.keys(this.config).map((key) => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(this.config[key])
    }).join('&')
  }

  query(text, center, callback) {
    this.latestQuery = text
    this.waiting = true

    this.fetch(text, center).then(data => {
      if (text == this.latestQuery) {
        console.log('[GeoSearchAPI]', text, data) // eslint-disable-line no-console
        this.waiting = false
        callback(this.parseServiceResponse(data.features))
      } else {
        console.log('[GeoSearchAPI]', 'Ignored expired request:', text) // eslint-disable-line no-console
      }
    }).catch(error => {
      console.error('[GeoSearchAPI]', 'Error:', error) // eslint-disable-line no-console
    })
  }

  parseServiceResponse(data) {
    const results = []
    
    // Showing only 8 results for now, potentially increase/descrease the number
    for (let i = 0; i < data.length; i++) {
      const dat = data[i]
      let result = {
        text: dat.place_name,
        latitude: dat.center[1],
        longitude: dat.center[0],
        type: dat.place_type[0],
      }

      if (['country', 'region', 'district'].includes(result.type)) {
        console.log(dat)
        result.west = dat.bbox[0]
        result.south = dat.bbox[1]
        result.east = dat.bbox[2]
        result.north = dat.bbox[3]
      }

      results.push(result)

    }

    return results
  }

  async fetch(text, center) {
    const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${text}.json?${this.config}&proximity=${center[1]},${center[0]}`

    // Default options are marked with *
    const response = await fetch(url, {
      method: 'GET', // *GET, POST, PUT, DELETE, etc.
      /*
      mode: 'no-cors', // no-cors, *cors, same-origin
      cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
      credentials: 'same-origin', // include, *same-origin, omit
      redirect: 'follow', // manual, *follow, error
      referrerPolicy: 'no-referrer', // no-referrer, *client
      headers: {
        'Content-Type': 'application/json'
      },
      */
    })

    return await response.json() // parses JSON response into native JavaScript objects
  }

}
