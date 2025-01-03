
class EventTiming {

  #online = null
  #timeZoneDateTime = null

  // Raw dates
  #firstDateTime = null
  #lastDateTime = null
  upcomingDateTimes = []

  // Date strings
  startDate = null
  endDate = null
  startTime = null
  endTime = null

  isUpcoming = null

  dateString = null
  timeString = null
  description = ''

  constructor(event) {
    const timing = event.timing

    this.#online = event.online
    this.#timeZoneDateTime = luxon.DateTime.local().setZone(timing.timeZone)

    if (event.type == 'inactive') return

    let firstDateTime = luxon.DateTime.fromISO(timing.firstDate)
    let lastDateTime = timing.lastDate ? luxon.DateTime.fromISO(timing.lastDate) : null
    this.#firstDateTime = firstDateTime
    this.#lastDateTime = lastDateTime

    this.upcomingDateTimes = timing.upcomingDates.map(datetime => luxon.DateTime.fromISO(datetime))
    this.isUpcoming = this.upcomingDateTimes.length > 0

    if (this.#online) {
      // Add user timezone for online classes
      const userTimeZone = luxon.DateTime.local().zoneName
      firstDateTime = firstDateTime.setZone(userTimeZone)
      lastDateTime = lastDateTime ? lastDateTime.setZone(userTimeZone) : null
      this.upcomingDateTimes = this.upcomingDateTimes.map(datetime => datetime.setZone(userTimeZone))
      this.#timeZoneDateTime = luxon.DateTime.local()
    } else {
      // Add local timezone for offline classes
      const localTimeZone = timing.timeZone
      firstDateTime = firstDateTime.setZone(localTimeZone)
      lastDateTime = lastDateTime ? lastDateTime.setZone(localTimeZone) : null
      this.upcomingDateTimes = this.upcomingDateTimes.map(datetime => datetime.setZone(localTimeZone))
      this.#timeZoneDateTime = luxon.DateTime.fromObject({ zone: localTimeZone })
    }

    this.startDate = firstDateTime.toLocaleString({ month: 'long', day: 'numeric' })
    this.endDate = lastDateTime ? lastDateTime.toLocaleString({ month: 'long', day: 'numeric' }) : null
    this.startTime = firstDateTime.toLocaleString(luxon.DateTime.TIME_SIMPLE)
    this.endTime = timing.duration ? firstDateTime.plus({ hours: timing.duration }).toLocaleString(luxon.DateTime.TIME_SIMPLE) : null
    this.duration = timing.duration

    this.timeString = this.endTime ? `${this.startTime} - ${this.endTime}` : this.startTime

    if (this.startDate == this.endDate) {
      this.dateString = this.startDate
    } else if (timing.recurrence == 'daily') {
      if (Boolean(this.lastOccurrence)) {
        this.dateString = `${this.startDate} - ${this.endDate}`
      } else {
        this.dateString = Util.translate('recurrence.day')
      }
    } else {
      let weekday = firstDateTime.toLocaleString({ weekday: 'long' })
      this.dateString = Util.translate(`recurrence.${timing.recurrence}`, { weekday: weekday })
    }

    if (this.#firstDateTime > luxon.DateTime.local()) {
      let displayDate = firstDateTime.toLocaleString({ month: 'short', day: 'numeric' })
      this.startingString = Util.translate('event.starting_date', { date: displayDate }).toUpperCase()
    }

    if (event.category == 'course' && event.timing.recurrenceCount) {
      if (event.timing.recurrence.startsWith('weekly_')) {
        this.description = Util.translate('timing_labels.course_weekly', { count: event.timing.recurrenceCount })
      } else if (event.timing.recurrence.startsWith('monthly_')) {
        this.description = Util.translate('timing_labels.course_monthly', { count: event.timing.recurrenceCount })
      } else {
        this.description = Util.translate('timing_labels.course_fallback')
      }
    } else if (timing.recurrence != 'day') {
      this.description = Util.translate('timing_labels.ongoing')
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

  #stripZ(time) {
    if (!time) return time

    const len = time.length
    if (time[len-1] == 'Z') {
      return time.substr(0, len - 1)
    } else {
      return time
    }
  }

}
