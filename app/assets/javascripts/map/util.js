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
    let text = dig(key.split('.'), window.translations) || ''
    Object.entries(vars).forEach(([field, value]) => {
      text = text.replace(`%{${field}}`, value)
    })

    return text
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
  }
}