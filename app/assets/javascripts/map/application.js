/* global AtlasAPI, MapView, Navbar, ListPanel, InfoPanel, ImageGallery, TimingCarousel, SharingModal */

class ApplicationInstance {

  constructor() {
    this.container = document.getElementById('map')

    this.mode = 'map'
    this.listPanel = new ListPanel(document.getElementById('js-list-panel'))
    this.infoPanel = new InfoPanel(document.getElementById('js-info-panel'))
    this.navbar = new Navbar(document.getElementById('js-navbar'))
    this.imageGallery = new ImageGallery(document.getElementById('js-image-gallery'))
    this.timingCarousel = new TimingCarousel(document.getElementById('js-timing-carousel'))
    this.share = new SharingModal(document.getElementById('js-share'))
    this.atlas = new AtlasAPI(this.container.dataset.api)
    this.history = new History()
    this.map = new MapView(this.container, () => this.loadState())

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

  showVenues(venues, allowFallback = false) {
    if (venues.length) {
      this.listPanel.showVenues(venues)
    } else if (allowFallback) {
      this.atlas.getClosest(this.map.getCenter(), response => {
        this.listPanel.showNoResults(response)
      })
    }
  }

  setState(state, recordHistory = true) {
    this.state = state
    this.infoPanel.hideMessages()
    
    if (state.label) {
      this.navbar.setText(state.label)
    }

    if (state.event) {
      // Show event
      this._setMode('event')
      this.infoPanel.show(state.event, state.venue)
      this.map.invalidateSize()
      this.map.setHighlightedVenue(state.venue)
    } else if (state.venue) {
      if (state.venue.events.length == 1) {
        // Show even if there is only one event for this venue
        return this.setState({ event: state.venue.events[0], venue: state.venue })
      }

      // Show venue
      this._setMode('venue')
      this.navbar.setVenue(state.venue)
      this.showVenues([state.venue])
      this.map.invalidateSize()
      this.map.setHighlightedVenue(state.venue)
    } else {
      this._setMode((this.state.zoom && this.state.zoom > 10) ? 'list' : 'map')
      this.map.invalidateSize()
      this.map.setHighlightedVenue(null)

      if (state.west && state.east && state.north && state.south) {
        this.listPanel.setEmptyResults(false)
        this.listPanel.clearEvents()
        this.map.fitTo(state)
        this.state.zoom = this.map.mapbox.getZoom()
      } else if (state.latitude && state.longitude) {
        this.listPanel.setEmptyResults(false)
        this.listPanel.clearEvents()
        this.map.flyTo(state, 10)
      } else {
        this.map.zoomOut()
      }

      if (['postcode', 'address'].includes(state.type)) {
        this.map.setLocation({
          latitude: state.latitude,
          longitude: state.longitude,
        })
      }
    }

    if (recordHistory) {
      this.history.push(state)
    }

    return true
  }

  replaceListState(state, wideZoom, recordHistory = true) {
    if (['list', 'map'].includes(this.mode)) {
      const targetState = wideZoom ? 'map' : 'list'
      
      if (recordHistory) {
        //this.history.replace(state)
      }

      if (wideZoom) {
        this.listPanel.clearEvents()
      }

      if (this.mode != targetState) {
        this._setMode(targetState)
        this.map.invalidateSize()
      }
    }
  }

  _setMode(mode) {
    if (this.mode) {
      document.body.classList.remove(`mode--${this.mode}`)
    }

    this.mode = mode

    if (this.mode) {
      document.body.classList.add(`mode--${this.mode}`)
      document.body.scrollTop = 0
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.Application = new ApplicationInstance()
})
