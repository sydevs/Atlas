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

  isMode(mode) {
    return document.body.classList.contains(`mode--${mode}`)
  },

  getURL(url, callback) {
    var xhttp
    xhttp = new XMLHttpRequest()
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        callback(this)
      }
    }

    xhttp.open('GET', url, true)
    xhttp.send()
  },

  postForm(url, formElement, callback) {
    var XHR = new XMLHttpRequest()
    // Bind the FormData object and the form element
    var formData = new FormData(formElement)

    // Define what happens on successful data submission
    XHR.addEventListener('load', function(event) {
      callback(event)
    })

    // Define what happens in case of error
    XHR.addEventListener('error', function(event) {
      callback(event)
    })

    // Set up our request
    XHR.open('POST', url)

    // The data sent is what the user provided in the form
    XHR.send(formData)
  },

  toggleZindex(element, zIndex) {
    element.style.zIndex = zIndex
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

  translate(key) {
    // Copied from: https://twitter.com/sharifsbeat/status/843187365367767046
    const dig = (p, o) => p.reduce((xs, x) => (xs && xs[x]) ? xs[x] : null, o)
    return dig(key.split('.'), window.translations)
  },

  parseTiming(timing) {
    if (timing.start_date == timing.end_date) {
      return Util.formatDate(timing.start_date)
    } else if (timing.recurrence == 'day' && timing.end_date) {
      return `${Util.formatDate(timing.start_date)} - ${Util.formatDate(timing.end_date)}`
    } else {
      return Util.translate(`recurrence.${timing.recurrence}`)
    }
  },

  parseEventCategoryDescription(event) {
    if (event.category == 'course') {
      const start_date = Date.parse(event.timing.start_date)
      const end_date = Date.parse(event.timing.end_date)

      if (start_date && end_date) {
        const weeksBetween = Math.round((start_date - end_date) / (7 * 24 * 60 * 60 * 1000))
        return Util.translate('timing_labels.course').replace('%{weeks}', Math.abs(weeksBetween))
      } else {
        return Util.translate('timing_labels.course_fallback')
      }
    } else if (event.recurrence == 'day') {
      return ''
    } else {
      return Util.translate('timing_labels.ongoing')
    }
  },

  formatDate(date) {
    if (!Util.formatter) {
      Util.formatter = new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' })
    }

    date = Date.parse(date)
    return Util.formatter.format(date)
  },

  distance(lat1, lon1, lat2, lon2, unit) {
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