/* globals Application, ListItem, Util */
/* exported ListPanel */

class ListPanel {

  constructor(element) {
    this.container = element
    this.activeItem = null
    this.itemTemplate = document.getElementById('js-item-template')
    this.closestVenueTitle = document.getElementById('js-list-closest-venue')
    this.closestVenueTitle.addEventListener('click', () => this.triggerAlternativeQuery())
    this.listModeContainer = document.getElementById('js-list-mode')

    let elements = document.getElementsByClassName('js-list-mode')
    for (let i = 0; i < elements.length; i++) {
      elements[i].addEventListener('click', event => {
        Application._setListingType(event.target.dataset.value)
      })
    }

    this.data = {}
    let types = ['online', 'offline']
    types.forEach(type => {
      this.data[type] = {
        items: {},
        container: document.getElementById(`js-list-${type}`),
        counters: document.querySelectorAll(`.js-list-mode[data-value="${type}"]`)
      }
    })
  }

  setEmptyResults(shown) {
    const wasShown = document.body.classList.contains('state--no-results')
    if (wasShown != shown) {
      document.body.classList.toggle('state--no-results', shown)
      Application.map.invalidateSize()
    }
  }

  /*showLoading() {
    this.setEmptyResults(false)
    this.reset()
  }*/

  showVenues(venues) {
    let type = 'offline'
    this.reset(type)

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
        this.appendEvent(type, event, venue)
      }
    }

    this.resetCounters(type)
  }

  showEvents(events, type) {
    this.reset(type)

    if (events.length < 1) return

    this.setEmptyResults(false)
    for (let n = 0; n < events.length; n++) {
      const event = events[n]
      if (type == 'offline') event.venueId = event.venue.id
      this.appendEvent(type, event, event.venue)
    }

    this.resetCounters(type)
  }

  appendEvent(type, event, venue = null) {
    const element = document.importNode(this.itemTemplate.content, true).querySelector('.js-item')
    this.data[type].items[event.id] = new ListItem(element, event, venue)
    this.data[type].container.appendChild(element)
  }

  showClosestVenue(venue, currentCenter) {
    this.setEmptyResults(true)
    this.reset('offline')

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

  triggerAlternativeQuery() {
    Application.navbar.select(this.closestVenueData)
  }

  toggleTypeInput(shown = null) {
    if (shown == null) shown = this.listModeContainer.style == 'display: none'
    this.listModeContainer.style = shown ? '' : 'display: none'
  }

  reset(type) {
    this.container.scrollTop = 0
    this.data[type].items = {}
    this.data[type].container.innerHTML = null
    this.resetCounters(type)
  }

  resetCounters(type) {
    let counters = this.data[type].counters
    let count = this.data[type].container.childElementCount

    for (let i = 0; i < counters.length; i++) {
      if (count > 0) {
        counters[i].dataset.count = count
      } else {
        delete counters[i].dataset.count
      }
    }
  }

}
