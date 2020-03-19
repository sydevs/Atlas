/* globals Application */
/* exported ListItem */

class ListItem {

  constructor(element, event, venue) {
    this.container = element
    this.event = event
    this.venue = venue
    element.querySelector('[data-attribute="name"]').textContent = event.label
    element.querySelector('[data-attribute="address"]').textContent = event.address
    element.querySelector('[data-attribute="distance"]').textContent = event.distance
    element.querySelector('[data-attribute="distance"]').style = (event.distance ? '' : 'display: none')
    element.querySelector('[data-attribute="day"]').textContent = event.timing.dates
    element.querySelector('[data-attribute="time"]').textContent = event.timing.times
    element.addEventListener('click', () => this.open())

    if (event.language.code && document.documentElement.lang.toUpperCase() != event.language.code) {
      element.querySelector('[data-attribute="language"]').textContent = event.language.code
    } else {
      element.querySelector('[data-attribute="language"]').remove()
    }
  }

  open() {
    Application.setState({ event: this.event, venue: this.venue })
  }

  setHidden(hidden) {
    this.container.classList.toggle('item--hidden', hidden)
  }

}
