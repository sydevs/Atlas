/* globals Application, Util */
/* exported ListItem */

class ListItem {

  constructor(element, event, venue = null) {
    this.container = element
    this.event = event
    this.venue = venue

    let distance = null
    const distanceElement = element.querySelector('[data-attribute="distance"]')

    if (venue) {
      distance = Application.map.distance(venue)
      distanceElement.textContent = `${Math.round(distance * 10) / 10} km`
    }

    distanceElement.style = (distance == null ? 'display: none' : '')

    element.querySelector('[data-attribute="name"]').textContent = event.label
    element.querySelector('[data-attribute="address"]').textContent = event.address
    element.querySelector('[data-attribute="day"]').textContent = Util.parseTiming(event.timing)
    element.querySelector('[data-attribute="time"]').textContent = event.timing.time
    element.addEventListener('click', () => this.open())

    if (event.language_code && document.documentElement.lang.toUpperCase() != event.language_code) {
      element.querySelector('[data-attribute="language"]').textContent = event.language_code
    } else {
      element.querySelector('[data-attribute="language"]').remove()
    }
  }

  open() {
    Application.showEvent(this.event, this.venue)
  }

  setHidden(hidden) {
    this.container.classList.toggle('item--hidden', hidden)
  }

}
