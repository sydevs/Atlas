/* globals Flickity */
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
    const timings = this.parseTiming(event.timing)
    const oldCells = this.flickity.cells.map(cell => cell.element)
    const newCells = timings.map(timing => this.createTimingItem(event, timing))
    this.flickity.remove(oldCells)
    this.flickity.append(newCells)
    this.flickity.select(0, false, true)
    this.flickity.resize()
  }

  parseTiming(timing) {
    const daily = (timing.recurrence == 'daily')
    const interval = (daily ? 1 : 7)
    const start_date = new Date(timing.start_date)
    const end_date = timing.end_date == null ? null : new Date(timing.end_date)
    let dates = []

    if (timing.start_date == timing.end_date || (timing.end_date == null && daily)) {
      return [start_date]
    } else if (daily) {
      dates.push(new Date(Math.min(start_date, new Date())))
    } else {
      let date = new Date()
      let targetDay = DAY_INDICES[timing.recurrence]
      date.setDate(date.getDate() + (targetDay + (7 - date.getDay())) % 7)
      dates.push(date)
    }

    while (dates.length < 10) {
      let next_date = new Date(dates[dates.length - 1])
      next_date.setDate(next_date.getDate() + interval)
      if (end_date != null && next_date > end_date) break

      dates.push(next_date)
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
    element.querySelector('[data-attribute="time"]').textContent = event.timing.time
    return element
  }

}
