/* global AtlasAPI, WorldMap, Navbar, ListPanel, InfoPanel, ImageGallery, TimingCarousel, SharingModal */

class ApplicationInstance {

  constructor() {
    this.container = document.getElementById('map')

    this.mode = null
    this.map = new WorldMap(this.container)
    this.listPanel = new ListPanel(document.getElementById('js-list-panel'))
    this.infoPanel = new InfoPanel(document.getElementById('js-info-panel'))
    this.navbar = new Navbar(document.getElementById('js-navbar'))
    this.imageGallery = new ImageGallery(document.getElementById('js-image-gallery'))
    this.timingCarousel = new TimingCarousel(document.getElementById('js-timing-carousel'))
    this.share = new SharingModal(document.getElementById('js-share'))
    this.atlas = new AtlasAPI(this.container.dataset.api)
    this.history = new History()

    if (this.container.dataset.restricted == 'true') {
      this.map.lockBounds()
    }
  }

  loadState() {
    const state = JSON.parse(this.container.dataset.state)

    if (state.event || state.venue) {
      this.history.push({ venues: state.venues })
    }

    this.setState(state)
  }

  setState(state, recordHistory = true) {
    this.state = state

    if (state.venues) {
      // Load venues
      this.listPanel.setVenues(state.venues)
      this.map.setVenueMarkers(state.venues)
    }

    if (state.event) {
      // Show event
      this._setMode('event')
      this.infoPanel.show(state.event)
      this.map.selectMarker(state.event.venue_id)
      this.map.zoomToVenue(state.event)
      this.setInteractive(false)
    } else if (state.venue) {
      // Show venue
      this._setMode('venue')
      this.navbar.setVenue(state.venue)
      this.listPanel.filterByVenue(state.venue)
      this.map.selectMarker(state.venue.id)
      this.map.invalidateViewportDimensions()
      this.map.zoomToVenue(state.venue)
      this.setInteractive(false)
    } else if (state.venues) {
      // Show list of venues
      this._setMode('list')
      this.navbar.setActive(false)
      this.map.scaleToMax()
      this.listPanel.resetFilter()
      this.map.selectMarker(null)
      this.map.invalidateViewportDimensions()
      this.map.fitToMarkers()
      this.setInteractive(true)
    } else if (state.alternatives) {
      // Show empty results with alternatives
      this._setMode('list')
      this.listPanel.showEmptyResults(state.alternatives[0])
      this.map.zoomTo(state.latitude, state.longitude)
      this.map.setVenueMarkers([])
    } else {
      console.error('Tried to set invalid state', state) // eslint-disable-line no-console
      return false
    }

    if (recordHistory) {
      this.history.push(state)
    }

    return true
  }

  setInteractive(interactive) {
    document.body.classList.toggle('map-interactive', interactive)
    this.map.setInteractive(interactive)
  }

  loadEvents(query) {
    this.atlas.query(query, response => {
      this.setState({ venues: response.results })
      this.map.setRefreshDisabled(false)
      this.map.setRefreshHidden(true)
    })
  }

  _setMode(mode) {
    if (this.mode) {
      document.body.classList.remove(`mode--${this.mode}`)
    }

    this.mode = mode

    if (this.mode) {
      document.body.classList.add(`mode--${this.mode}`)
      document.body.scrollTop = 0
      this.map.leaflet.invalidateSize()
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.Application = new ApplicationInstance()
  window.Application.loadState()
})
