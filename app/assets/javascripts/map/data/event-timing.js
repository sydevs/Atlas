
class EventTiming {

  #online
  #timeZoneDateTime

  // Raw dates
  #firstDateTime
  #lastDateTime
  upcomingDateTimes

  // Date strings
  startDate
  endDate
  startTime
  endTime

  isUpcoming

  dateString
  timeString
  description = ''

  constructor(event) {
    const timing = event.timing
    const localTimeZone = luxon.DateTime.local().zoneName
    let firstDateTime = luxon.DateTime.fromISO(timing.firstDate, { zone: timing.timeZone })
    let lastDateTime = timing.lastDate ? luxon.DateTime.fromISO(timing.lastDate, { zone: timing.timeZone }) : null
    this.upcomingDateTimes = timing.upcomingDates.map(datetime => luxon.DateTime.fromISO(datetime, { zone: event.timing.timeZone }))
    this.isUpcoming = this.upcomingDateTimes.length > 0

    this.#online = event.online
    this.#timeZoneDateTime = luxon.DateTime.local().setZone(timing.timeZone)

    if (event.online) {
      firstDateTime = firstDateTime.setZone(localTimeZone)
      lastDateTime = lastDateTime ? lastDateTime.setZone(localTimeZone) : null
      this.upcomingDateTimes.map(datetime => datetime.setZone(localTimeZone))
    }

    this.startDate = firstDateTime.toLocaleString({ month: 'long', day: 'numeric' })
    this.endDate = lastDateTime ? lastDateTime.toLocaleString({ month: 'long', day: 'numeric' }) : null
    this.startTime = firstDateTime.toLocaleString(luxon.DateTime.TIME_SIMPLE)
    this.endTime = timing.duration ? firstDateTime.plus({ hours: timing.duration }).toLocaleString(luxon.DateTime.TIME_SIMPLE) : null
    this.duration = timing.duration

    this.timeString = this.endTime ? `${this.startTime} - ${this.endTime}` : this.startTime

    if (this.startDate == this.endDate) {
      this.dateString = this.startDate
    } else if (timing.recurrence == 'day' && Boolean(this.lastOccurrence)) {
      this.dateString = `${this.startDate} - ${this.endDate}`
    } else {
      let weekday = firstDateTime.toLocaleString({ weekday: 'long' })
      this.dateString = Util.translate(`recurrence.${weekday.toLowerCase()}`)
    }

    if (event.category == 'course') {
      if (firstDateTime && lastDateTime) {
        const weeksBetween = Math.round((firstDateTime - lastDateTime) / (7 * 24 * 60 * 60 * 1000)) + 1
        this.description = Util.translate('timing_labels.course', {
          weeks: Math.abs(weeksBetween)
        })
      } else {
        this.description = Util.translate('timing_labels.course_fallback')
      }
    } else if (timing.recurrence != 'day') {
      return Util.translate('timing_labels.ongoing')
    }
  }

  get minutesUntilNextDateTime() {
    const diffMilliseconds = this.nextDateTime - luxon.DateTime.local()
    const diffMinutes = Math.floor((diffMilliseconds / 1000) / 60)
    return diffMinutes > 0 ? diffMinutes : Infinity
  }

  get startingSoon() {
    return this.#online ? this.minutesUntilNextDateTime < 60 : false
  }

  get nextDateTime() {
    return this.upcomingDateTimes[0]
  }

  get firstDateTime() {
    return this.#firstDateTime
  }

  timeZone(format = 'long') {
    return this.#timeZoneDateTime.toFormat(format == 'short' ? 'ZZZZ' : 'ZZZZZ')
  }

}
