
const Data = {
  events: null,
  venues: null,

  load() {
    console.log('loading data.js')
    let data = L.DomUtil.get('data')
    Data.events = JSON.parse(data.dataset.events)
    Data.venues = {}

    for (let id in Data.events) {
      let event = Data.events[id]
      Data.venues[event.venue.id] = event.venue
      event.upcoming_dates = Data.processUpcomingDates(event.upcoming_dates)
    }
  },

  processUpcomingDates(dates) {
    result = []
    current_month = null

    for (let i = 0; i < dates.length; i++) {
      const date = new Date(dates[i])
      let month = date.toLocaleDateString(undefined, { month: 'long', year: 'numeric' })
      let day = date.getDate().toString()

      if (day.length == 1) {
        day = '0' + day
      }

      // We are operating on the assumption that the dates are all ordered.
      if (month != current_month) {
        result.push([month])
        current_month = month
      }

      result[result.length - 1].push(day)
    }

    return result
  }

}
