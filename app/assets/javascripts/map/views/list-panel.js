/* globals Application, ListItem */
/* exported ListPanel */

class ListPanel {

  constructor(element) {
    this.container = element
    this.activeItem = null
    this.items = []
    this.itemTemplate = document.getElementById('js-item-template')
    this.itemsContainer = document.getElementById('js-list-results')
    this.noResultsAlternativeTitle = document.getElementById('js-list-alternative')
    this.noResultsAlternativeTitle.addEventListener('click', () => this.triggerAlternativeQuery())
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
    this.clearEvents()
  }

  showNoResults(alternative) {
    this.alternative = alternative
    this.setEmptyResults(true)

    if (alternative) {
      this.noResultsAlternativeTitle.innerText = alternative.label
    }
  }

  showVenues(venues) {
    this.venues = venues
    this.clearEvents()

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

  clearEvents() {
    this.itemsContainer.innerHTML = null
    this.items = []
  }

  appendEvent(event, venue) {
    const element = document.importNode(this.itemTemplate.content, true).querySelector('.js-item')
    this.items[event.id] = new ListItem(element, event, venue)
    this.itemsContainer.appendChild(element)
  }

  triggerAlternativeQuery() {
    Application.navbar.select(this.alternative)
  }

}
