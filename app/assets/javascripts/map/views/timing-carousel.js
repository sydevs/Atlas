/* globals Flickity */
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

  setTimings(event, timings) {
    const cells = timings.map(timing => this.createTimingItem(event, timing))
    this.flickity.remove(this.flickity.cell)
    this.flickity.append(cells)
    this.flickity.select(0, false, true)
    this.flickity.resize()
  }

  createTimingItem(event, datetime) {
    const element = document.importNode(this.template.content, true).querySelector('.js-timing')

    const date = new Date(datetime)
    let weekday = date.toLocaleDateString(undefined, { weekday: 'long' })
    weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1)
    let dateString = date.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
    weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1)

    element.querySelector('[data-attribute="datetime"]').value = datetime
    element.querySelector('[data-attribute="day"]').innerText = weekday
    element.querySelector('[data-attribute="date"]').innerText = dateString
    element.querySelector('[data-attribute="time"]').textContent = event.timing.time
    return element
  }

}
