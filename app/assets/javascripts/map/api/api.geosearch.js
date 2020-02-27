/* globals */
/* exported GeoSearchAPI */

class GeoSearchAPI {

  constructor(key, country) {
    this.config = {
      access_token: key,
      format: 'json',
      autocomplete: true,
      language: document.documentElement.lang,
      types: 'region,postcode,district,place,locality,neighborhood,address'
    }

    if (country) {
      this.config.country = country
    }

    this.config = Object.keys(this.config).map((key) => {
      return encodeURIComponent(key) + '=' + encodeURIComponent(this.config[key])
    }).join('&')
  }

  query(text, callback) {
    this.latestQuery = text
    this.waiting = true

    this.fetch(text).then(data => {
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

      results.push({
        label: dat.place_name,
        latitude: dat.center[0],
        longitude: dat.center[1],
      })
    }

    return results
  }

  async fetch(text) {
    const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${text}.json?${this.config}`

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
