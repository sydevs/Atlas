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

  getEventsForVenue(venue) {
    return this.items.map(item => { return item.event.venue_id == venue.id ? item.event : null }).filter(Boolean)
  }

  filterByVenue(venue) {
    this.items.forEach(item => item.setHidden(item.event.venue_id != venue.id))
    this.container.classList.add('listing--filtered')
  }

  resetFilter(zoom = false) {
    this.items.forEach(item => item.setHidden(false))
    this.container.classList.remove('listing--filtered')
    if (zoom) Application.map.fitToMarkers()
  }

  clearEvents() {
    this.itemsContainer.innerHTML = null
    this.items = []
  }

  setVenues(venues) {
    this.venues = venues
    this.clearEvents()
    this.resetFilter()

    this.container.classList.toggle('list--no-results', venues.length == 0)
    for (let i = 0; i < venues.length; i++) {
      const venue = venues[i]
      let events = venue.events

      for (let n = 0; n < events.length; n++) {
        const event = events[n]
        event.venue_id = venue.id
        this.appendEvent(event)
      }
    }
  }

  appendEvent(event) {
    const element = document.importNode(this.itemTemplate.content, true).querySelector('.js-item')
    this.items[event.id] = new ListItem(element, event)
    this.itemsContainer.appendChild(element)
  }

  showEmptyResults(alternative) {
    this.clearEvents()
    this.resetFilter()

    this.alternative = alternative
    this.container.classList.add('list--no-results')

    if (alternative) {
      this.noResultsAlternativeTitle.innerText = alternative.label
    }
  }

  triggerAlternativeQuery() {
    Application.navbar.select(this.alternative.query)
  }

}
