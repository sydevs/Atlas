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

    this.defaultZoom = {
      region: 6,
      district: 7,
      place: 8,
      default: 10,
    }

    if (this.container.dataset.restricted == 'true') {
      this.map.lockBounds()
    }

    // Workaround for an iOS bug that causes grey blocks when you focus an input
    const inputs = document.querySelectorAll('input, textarea')
    inputs.forEach(input => {
      input.addEventListener('focus', () => window.scrollBy(0, 0))
    })
  }

  loadState() {
    const state = JSON.parse(this.container.dataset.state)

    if (state.event || state.venue) {
      let old_state = Object.assign({}, state)
      delete old_state.event
      delete old_state.venue
      this.history.push(old_state)
    }

    this.setState(state)
  }

  setState(state, recordHistory = true, disableZoom = false) {
    this.state = state

    if (state.venues) {
      // Load venues
      this.listPanel.setVenues(state.venues)
      this.map.setVenueMarkers(state.venues)
    }
    
    if (state.query) {
      this.navbar.setText(state.query)
    }

    if (state.event) {
      // Show event
      this._setMode('event')
      this.infoPanel.show(state.event)
      this.map.selectMarker(state.event.venue_id)
      if (!disableZoom) this.map.zoomToVenue(state.event)
      this.setInteractive(false)
    } else if (state.venue) {
      const venue_events = this.listPanel.getEventsForVenue(state.venue)
      if (venue_events.length == 1) {
        // Show even if there is only one event for this venue
        return this.setState({ event: venue_events[0] })
      }

      // Show venue
      this._setMode('venue')
      this.navbar.setVenue(state.venue)
      this.listPanel.filterByVenue(state.venue)
      this.map.selectMarker(state.venue.id)
      this.map.invalidateViewportDimensions()
      if (!disableZoom) this.map.zoomToVenue(state.venue)
      this.setInteractive(false)
    } else if (state.venues) {
      // Show list of venues
      this._setMode('list')
      this.navbar.setActive(false)
      this.map.scaleToMax()
      this.listPanel.resetFilter()
      this.map.selectMarker(null)
      this.map.invalidateViewportDimensions()
      if (!disableZoom) this.map.fitToMarkers()
      this.setInteractive(true)
    } else if (state.alternatives) {
      // Show empty results with alternatives
      this._setMode('list')
      this.listPanel.showEmptyResults(state.alternatives[0])
      if (state.type) {
        this.map.zoomTo(state.latitude, state.longitude, this.defaultZoom[state.type] || this.defaultZoom.default)
      }

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

  loadEvents(query, disableZoom = false) {
    this.atlas.query(query, response => {
      if (response.status == 'empty') {
        this.setState({
          message: response.results.message,
          latitude: query.latitude,
          longitude: query.longitude,
          type: query.type,
          alternatives: response.results.alternatives,
        }, true)
      } else {
        this.setState({
          query: query.query,
          latitude: query.latitude,
          longitude: query.longitude,
          type: query.type,
          venues: response.results,
        }, true, disableZoom)
      }

      if (['postcode', 'address'].includes(query.type)) {
        this.map.setTargetMarker(query)
      }

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
