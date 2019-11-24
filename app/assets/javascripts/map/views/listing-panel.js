/* globals Application, ListingItem */
/* exported ListingPanel */

class ListingPanel {

  constructor(element) {
    this.container = element
    this.activeItem = null
    this.items = []
    this.itemTemplate = document.getElementById('js-item-template')
    this.itemsContainer = document.getElementById('js-list-results')
    this.filterText = element.querySelector('.js-filter-text')
    element.querySelector('.js-reset').addEventListener('click', () => this.resetFilter(true))
  }

  show() {
    this.container.classList.add('panel--active')
  }

  hide() {
    this.container.classList.remove('panel--active')
  }

  filterByVenue(venue) {
    this.items.forEach(item => item.setHidden(item.event.venue_id != venue.id))
    this.container.classList.add('listing--filtered')
    this.filterText.textContent = venue.address.street || ''
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

  setEvents(events) {
    this.clearEvents()
    this.resetFilter()

    this.container.classList.toggle('listing--no-result', events.length == 0)
    for (let i = 0; i < events.length; i++) {
      this.appendEvent(events[i])
    }
  }

  appendEvent(event) {
    const element = document.importNode(this.itemTemplate.content, true).querySelector('.js-item')
    this.items[event.id] = new ListingItem(element, event)
    this.itemsContainer.appendChild(element)
  }

  setActiveItem(id) {
    if (this.activeItem) {
      this.activeItem.setActive(false)
    }

    this.activeItem = id ? this.items[id] : null

    if (this.activeItem) {
      this.activeItem.setActive(true)
    }
  }

}
