/* globals Flickity, Util, luxon */
/* exported TimingCarousel */

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

    const timings = Util.parseEventTiming(event, 'occurrences')
    const newCells = timings.map(timing => this.createTimingItem(event, timing))
    this.flickity.append(newCells)
    this.flickity.select(0, false, true)
    this.flickity.resize()
  }

  createTimingItem(event, date) {
    const element = document.importNode(this.template.content, true).querySelector('.js-timing')
    date = date.setLocale(window.locale)

    element.querySelector('[data-attribute="datetime"]').value = date.toISO().substring(0, 10)
    element.querySelector('[data-attribute="day"]').innerText = date.toLocaleString({ weekday: 'long' })
    element.querySelector('[data-attribute="date"]').innerText = date.toLocaleString({ month: 'long', day: 'numeric' })
    element.querySelector('[data-attribute="time"]').textContent = date.toLocaleString(luxon.DateTime.TIME_SIMPLE)

    return element
  }

}
