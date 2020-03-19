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

  showLoading() {
    this.container.classList.remove('list--no-results')
    this.clearEvents()
  }

  showNoResults(alternative) {
    this.alternative = alternative
    this.container.classList.add('list--no-results')

    if (alternative) {
      this.noResultsAlternativeTitle.innerText = alternative.label
    }
  }

  showVenues(venues) {
    this.venues = venues
    this.clearEvents()

    if (venues.length) {
      this.container.classList.remove('list--no-results')

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

  clearEmptyResults() {
    this.container.classList.remove('list--no-results')
  }

  showEmptyResults(alternative) {
    this.clearEvents()

    this.alternative = alternative
    this.container.classList.add('list--no-results')

    if (alternative) {
      this.noResultsAlternativeTitle.innerText = alternative.label
    }
  }

  triggerAlternativeQuery() {
    Application.navbar.select(this.alternative)
  }

}
