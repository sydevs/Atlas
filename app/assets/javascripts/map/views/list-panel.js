/* globals Application, ListItem, Util */
/* exported ListPanel */

class ListPanel {

  constructor(element) {
    this.container = element
    this.activeItem = null
    this.items = []
    this.itemTemplate = document.getElementById('js-item-template')
    this.itemsContainer = document.getElementById('js-list-results')
    this.modeInputs = document.getElementById('js-list-mode').querySelectorAll('input')
    this.closestVenueTitle = document.getElementById('js-list-closest-venue')
    this.closestVenueTitle.addEventListener('click', () => this.triggerAlternativeQuery())

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
        event.venueId = venue.id
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

  showClosestVenue(venue, currentCenter) {
    this.setEmptyResults(true)
    this.reset()

    if (venue) {
      const distance = Util.distance(venue.latitude, venue.longitude, currentCenter.latitude, currentCenter.longitude)
      const venueIsClose = distance < 8
      this.closestVenueData = {
        label: venueIsClose ? venue.label : `${venue.city}, ${venue.countryCode}`,
        latitude: venue.latitude,
        longitude: venue.longitude,
        zoom: venueIsClose ? 14 : 11,
      }
      
      this.closestVenueTitle.innerText = this.closestVenueData.label
      this.container.classList.toggle('list__no-results--far', !venueIsClose)
      this.container.classList.toggle('list__no-results--close', venueIsClose)
    } else {
      this.closestVenueData = null
      this.container.classList.remove('list__no-results--far')
      this.container.classList.remove('list__no-results--close')
    }
  }

  appendEvents(events, venue = null) {
    for (let n = 0; n < events.length; n++) {
      const event = events[n]
      event.venueId = venue ? venue.id : null
      this.appendEvent(event, venue)
    }
  }

  appendEvent(event, venue = null) {
    const element = document.importNode(this.itemTemplate.content, true).querySelector('.js-item')
    this.items[event.id] = new ListItem(element, event, venue)
    this.itemsContainer.appendChild(element)
  }

  triggerAlternativeQuery() {
    Application.navbar.select(this.closestVenueData)
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

  toggleTypeInput(shown = null) {
    const parent = this.modeInputs[0].parentElement.parentElement
    if (shown == null) shown = parent.style == 'display: none'
    parent.style = shown ? '' : 'display: none'
  }

  reset() {
    this.container.scrollTop = 0
    this.itemsContainer.innerHTML = null
    this.items = []
  }

}
