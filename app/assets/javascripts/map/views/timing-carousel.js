/* globals Flickity, Util */
/* exported TimingCarousel */

const DAY_INDICES = {
  sunday: 0,
  monday: 1,
  tuesday: 2,
  wednesday: 3,
  thursday: 4,
  friday: 5,
  saturday: 6
}

class TimingCarousel {

  constructor(element) {
    this.container = element
    this.template = document.getElementById('js-timing-template')
    this.selectedIndex = null

    this.flickity = new Flickity(element, {
      setGallerySize: false,
      pageDots: false,
    })

    this.flickity.on('select', (index) => {
      const cells = this.flickity.getCellElements()

      if (this.selectedIndex) {
        cells[this.selectedIndex].querySelector('.js-timing-value').disabled = true
      }

      this.selectedIndex = index
      cells[index].querySelector('.js-timing-value').disabled = false
    })
  }

  setTimings(event) {
    const oldCells = this.flickity.cells.map(cell => cell.element)
    this.flickity.remove(oldCells)

    const timings = this.parseTiming(event.timing)
    const newCells = timings.map(timing => this.createTimingItem(event, timing))
    this.flickity.append(newCells)
    this.flickity.select(0, false, true)
    this.flickity.resize()
  }

  parseTiming(timing, limit = 7) {
    const daily = (timing.recurrence == 'day')
    const interval = (daily ? 1 : 7)
    const endDate = timing.endDate == null ? null : new Date(timing.endDate)
    const today = new Date()
    let startDate = new Date(`${timing.startDate} ${timing.startTime}`)
    let dates = []

    if (startDate < today) {
      startDate = today
    }

    if (timing.startDate == timing.endDate) {
      return [startDate]
    } else if (daily) {
      dates.push(new Date(Math.min(startDate, new Date())))
    } else {
      let date = new Date()
      let targetDay = DAY_INDICES[timing.recurrence]
      date.setDate(date.getDate() + (targetDay + (7 - date.getDay())) % 7)
      dates.push(date)
    }

    while (dates.length < limit) {
      let nextDate = new Date(dates[dates.length - 1])
      nextDate.setDate(nextDate.getDate() + interval)
      if (endDate != null && nextDate > endDate) break

      dates.push(nextDate)
    }

    return dates
  }

  createTimingItem(event, date) {
    const element = document.importNode(this.template.content, true).querySelector('.js-timing')

    let weekday = date.toLocaleDateString(undefined, { weekday: 'long' })
    weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1)
    let dateString = date.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
    weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1)

    element.querySelector('[data-attribute="datetime"]').value = date.toISOString().substring(0, 10)
    element.querySelector('[data-attribute="day"]').innerText = weekday
    element.querySelector('[data-attribute="date"]').innerText = dateString
    element.querySelector('[data-attribute="time"]').textContent = Util.parseTime(event.timing)

    return element
  }

}
