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

  translateWeekday(weekday) {
    return Util.translate(`recurrence.${weekday.toLowerCase()}`)
  },

  parseEventTiming(event, type) {
    const localTimeZone = luxon.DateTime.local().zoneName
    let startDateTime = luxon.DateTime.fromISO(event.firstOccurrence, { zone: event.timing.timeZone })
    let nextDateTime = luxon.DateTime.fromISO(event.upcomingOccurrences[0], { zone: event.timing.timeZone })
    let endDateTime = event.lastOccurrence ? luxon.DateTime.fromISO(event.lastOccurrence, { zone: event.timing.timeZone }) : null

    if (event.online) {
      startDateTime = startDateTime.setZone(localTimeZone)
      nextDateTime = nextDateTime.setZone(localTimeZone)
      if (endDateTime) endDateTime = endDateTime.setZone(localTimeZone)
    }
    
    const startDateString = startDateTime.toLocaleString({ month: 'long', day: 'numeric' })
    const endDateString = endDateTime ? endDateTime.toLocaleString({ month: 'long', day: 'numeric' }) : null

    switch (type) {
    case 'startDate':
      return startDateString
    case 'startTime':
      return startDateTime.toLocaleString(luxon.DateTime.TIME_SIMPLE)
    case 'recurrence':
      if (startDateString == endDateString) {
        return startDateString
      } else if (event.timing.recurrence == 'day' && Boolean(event.lastOccurrence)) {
        return `${startDateString} - ${endDateString}`
      } else {
        return Util.translateWeekday(nextDateTime.toLocaleString({ weekday: 'long' }))
      }
    case 'duration': {
      const startTime = nextDateTime.toLocaleString(luxon.DateTime.TIME_SIMPLE)

      if (event.duration) {
        const endTime = nextDateTime.plus({ hours: event.duration }).toLocaleString(luxon.DateTime.TIME_SIMPLE)
        return `${startTime} - ${endTime}`
      } else {
        return startTime
      }
    }
    case 'occurrences':
      return event.upcomingOccurrences.map(datetime => {
        datetime = luxon.DateTime.fromISO(datetime, { zone: event.timing.timeZone })
        return event.online ? datetime.setZone(localTimeZone) : datetime
      })
    case 'shortTimeZone':
      return nextDateTime.toFormat('ZZZZ')
    case 'longTimeZone':
      return nextDateTime.toFormat('ZZZZZ')
    default:
      return null
    }
  },

  parseEventCategoryDescription(event) {
    if (event.category == 'course') {
      const startDate = Date.parse(event.timing.startDate)
      const endDate = Date.parse(event.timing.endDate)

      if (startDate && endDate) {
        const weeksBetween = Math.round((startDate - endDate) / (7 * 24 * 60 * 60 * 1000))
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