/* globals Application, ListItem */
/* exported ListPanel */

class ListPanel {

  constructor(element) {
    this.container = element
    this.activeItem = null
    this.items = []
    this.itemTemplate = document.getElementById('js-item-template')
    this.itemsContainer = document.getElementById('js-list-results')
    this.modeInputs = document.getElementById('js-list-mode').querySelectorAll('input')
    this.noResultsAlternativeTitle = document.getElementById('js-list-alternative')
    this.noResultsAlternativeTitle.addEventListener('click', () => this.triggerAlternativeQuery())

    for (let i = 0; i < this.modeInputs.length; i++) {
      this.modeInputs[i].addEventListener('change', event => Application._setListingType(event.target.value))
    }
  }

  setEmptyResults(shown) {
    const was_shown = document.body.classList.contains('state--no-results')
    if (was_shown != shown) {
      document.body.classList.toggle('state--no-results', shown)
      Application.map.invalidateSize()
    }
  }

  showLoading() {
    this.setEmptyResults(false)
    this.reset()
  }

  showNoResults(alternative) {
    this.alternative = alternative
    this.setEmptyResults(true)
    this.reset()

    if (alternative) {
      const event_label = alternative.event ? alternative.event.label : null
      this.noResultsAlternativeTitle.innerText = event_label || alternative.label
      this.container.classList.toggle('list__no-results--far', !alternative.close)
      this.container.classList.toggle('list__no-results--close', alternative.close)
    }
  }

  showVenues(venues) {
    this.reset()

    if (venues.length < 1) return

    this.setEmptyResults(false)

    if (Application.map.location) {
      venues.map(venue => venue.distance = Application.map.distance(venue))
      venues.sort((a, b) => a.distance - b.distance)
    }

    for (let i = 0; i < venues.length; i++) {
      const venue = venues[i]
      let events = venue.events

      for (let n = 0; n < events.length; n++) {
        const event = events[n]
        event.venue_id = venue.id
        this.appendEvent(event, venue)
      }
    }
  }

  showOnlineEvents(events) {
    this.reset()

    if (events.length < 1) return

    this.setEmptyResults(false)
    this.appendEvents(events)
  }

  appendEvents(events, venue = null) {
    for (let n = 0; n < events.length; n++) {
      const event = events[n]
      event.venue_id = venue ? venue.id : null
      this.appendEvent(event, venue)
    }
  }

  appendEvent(event, venue = null) {
    const element = document.importNode(this.itemTemplate.content, true).querySelector('.js-item')
    this.items[event.id] = new ListItem(element, event, venue)
    this.itemsContainer.appendChild(element)
  }

  triggerAlternativeQuery() {
    Application.navbar.select(this.alternative)
  }

  selectType(mode) {
    for (let i = 0; i < this.modeInputs.length; i++) {
      const element = this.modeInputs[i]

      if (element.value == mode) {
        element.checked = true
        return
      }
    }
  }

  reset() {
    this.container.scrollTop = 0
    this.itemsContainer.innerHTML = null
    this.items = []
  }

}
