/* globals Application, Util */
/* exported ListItem */

class ListItem {

  constructor(element, event, venue = null) {
    console.log(event)
    this.container = element
    this.event = event
    this.venue = venue

    let distance = null
    const distanceElement = element.querySelector('[data-attribute="distance"]')

    if (venue && Application.map) {
      distance = Application.map.distance(venue)
      distanceElement.textContent = `${Math.round(distance * 10) / 10} km`
    }

    distanceElement.style = (distance == null ? 'display: none' : '')

    this.elements = {}
    const attributes = ['name', 'address', 'day', 'time', 'timezone', 'language']
    attributes.forEach(attribute => {
      this.elements[attribute] = this.container.querySelector(`[data-attribute="${attribute}"]`)
    })

    this.elements.name.textContent = event.label
    this.elements.address.textContent = event.address
    this.elements.day.textContent = Util.parseEventTiming(event, 'recurrence')
    this.elements.time.textContent = Util.parseEventTiming(event, 'duration')

    if (event.online) {
      this.elements.timezone.textContent = Util.parseEventTiming(event, 'shortTimeZone')
      this.elements.timezone.dataset.title = Util.parseEventTiming(event, 'longTimeZone')
    } else {
      this.elements.timezone.remove()
    }

    element.addEventListener('click', () => this.open())

    if (event.languageCode && document.documentElement.lang.toUpperCase() != event.languageCode) {
      this.elements.language.textContent = Util.translate(`language_codes.${event.languageCode.toLowerCase()}`) || event.languageCode
    } else {
      this.elements.language.remove()
    }
  }

  open() {
    Application.showEvent(this.event, this.venue)
  }

  setHidden(hidden) {
    this.container.classList.toggle('item--hidden', hidden)
  }

}
