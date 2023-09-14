/* global luxon */
/* exported Util */

const Util = {

  isDevice(device) {
    if (window.innerWidth < 768) {
      return device == 'mobile'
    } else if (window.innerWidth > 1100) {
      return device == 'desktop'
    } else {
      return device == 'tablet'
    }
  },

  simpleFormat(str) {
    str = str.replace(/\r\n?/g, '\n')
    str = str.trim(str)

    if (str.length > 0) {
      str = str.replace(/\n\n+/g, '</p><p>')
      str = str.replace(/\n/g, '<br />')
      str = '<p>' + str + '</p>'
    }

    return str
  },

  translate(key, vars = {}) {
    // Copied from: https://twitter.com/sharifsbeat/status/843187365367767046
    const dig = (p, o) => p.reduce((xs, x) => (xs && xs[x]) ? xs[x] : null, o)
    let text = dig(key.split('.'), window.sya.translations) || ''
    Object.entries(vars).forEach(([field, value]) => {
      text = text.replace(`%{${field}}`, value)
    })

    return text
  },

  distance_between(p1, p2) {
    return Util.distance(p1.latitude, p1.longitude, p2.latitude, p2.longitude)
  },

  distance(lat1, lon1, lat2, lon2, unit = 'K') {
    if ((lat1 == lat2) && (lon1 == lon2)) {
      return 0
    } else {
      var radlat1 = Math.PI * lat1 / 180
      var radlat2 = Math.PI * lat2 / 180
      var theta = lon1 - lon2
      var radtheta = Math.PI * theta / 180
      var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta)
      if (dist > 1) {
        dist = 1
      }
      dist = Math.acos(dist)
      dist = dist * 180 / Math.PI
      dist = dist * 60 * 1.1515
      if (unit == 'K') { dist = dist * 1.609344 }
      if (unit == 'N') { dist = dist * 0.8684 }
      return dist
    }
  },

  toTitleCase(str) {
    return str.replace(
      /\w\S*/g,
      function(txt) {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
      }
    )
  },

  areArraysEqual(a1, a2) {
    /* WARNING: arrays must not contain {objects} or behavior may be undefined */
    return JSON.stringify(a1) == JSON.stringify(a2)
  },

  withProtocol(url) {
    if (!/^https?:\/\//i.test(url)) {
      return '//' + url
    } else {
      return url
    }
  },

  modifyURLParameters(url, add = [], remove = []) {
    let path = false

    if (typeof URLSearchParams !== 'undefined') {
      if (url[0] == "/") {
        path = url
        url = window.location.origin + path
      }

      url = new URL(url)
      const params = new URLSearchParams(url.search)

      add.forEach((value) => {
        parts = value.split('=')
        params.set(parts[0], parts[1])
      })
      
      remove.forEach(key => {
        params.delete(key)
      })

      if (path) {
        return `${url.pathname}?${params.toString()}${url.hash}`
      } else {
        return `${url.origin}${url.pathname}?${params.toString()}${url.hash}`
      }
    } else {
      console.log(`Your browser ${navigator.appVersion} does not support URLSearchParams`)
    }
  },

  withProtocol(url) {
    if (!/^https?:\/\//i.test(url)) {
      return '//' + url
    } else {
      return url
    }
  },
}