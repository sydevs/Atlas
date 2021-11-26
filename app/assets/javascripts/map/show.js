/* global AtlasAPI, MapView, Navbar, ListPanel, ListToggle, InfoPanel, ImageGallery, TimingCarousel, SharingModal */
/* exported MapApplicationInstance */

class MapApplicationInstance {

  constructor() {
    this.container = document.getElementById('map')

    this.listingType = document.body.dataset.list
    this.mode = 'map'
    this.listPanel = new ListPanel(document.getElementById('js-list-panel'))
    this.infoPanel = new InfoPanel(document.getElementById('js-info-panel'))
    this.navbar = new Navbar(document.getElementById('js-navbar'))
    this.imageGallery = new ImageGallery(document.getElementById('js-image-gallery'))
    this.timingCarousel = new TimingCarousel(document.getElementById('js-timing-carousel'))
    this.listToggle = new ListToggle(document.getElementById('js-list-toggle'))
    this.share = new SharingModal(document.getElementById('js-share'))
    this.atlas = new AtlasAPI()

    // Workaround for an iOS bug that causes grey blocks when you focus an input
    const inputs = document.querySelectorAll('input, textarea')
    inputs.forEach(input => {
      input.addEventListener('focus', () => window.scrollBy(0, 0))
    })
  }

  loadMap() {
    const state = JSON.parse(this.container.dataset.state)
    this.map = new MapView(this.container, state.venue)

    if (state.event) {
      this.showEvent(state.event, state.venue)
    } else if (state.venue) {
      this.showVenue(state.venue)
    } else {
      const wideZoom = this.map.isZoomWide()
      this._setMode(wideZoom ? 'map' : 'list')
    }

    this.currentMapOverview = null // There is no previous map overview

    this.atlas.getOnlineEvents(this.map.getCenter(), events => {
      this.showOnlineEvents(events)
    })
  }

  showVenues(venues, allowFallback = false) {
    if (venues.length) {
      this.listPanel.showVenues(venues)
    } else if (allowFallback) {
      const center = this.map.getCenter()
      this.atlas.getClosestVenue(center, venue => {
        this.listPanel.showClosestVenue(venue, center)
      })
    } else {
      this.listPanel.reset('offline')
    }
  }

  showOnlineEvents(events) {
    this.listPanel.showEvents(events, 'online')
  }

  showEvent(event, venue) {
    if (this.currentVenue && this.currentVenue.id != event.venueId) {
      this.currentVenue = null
    }

    this.saveMapState()
    this._setMode('event')
    this.infoPanel.show(event, venue)
    if (venue) {
      this.showVenues([venue])
      this.map.setHighlightedVenue(venue)
      this.listPanel.toggleTypeInput(false)
    }

    this.listPanel.toggleTypeInput(Boolean(venue))
    this.infoPanel.hideMessages()
    this.saveHistoryState(`/map/event/${event.id}`, venue)
  }

  showVenue(venue) {
    if (this.listingType == 'online') {
      this.map.updateRenderedVenues()
      this._setListingType('offline')
    }

    if (venue.events.length > 1) {
      this.saveMapState()
      this._setMode('venue')
      this.navbar.setVenue(venue)
      this.showVenues([venue])
      this.map.invalidateSize()
      this.map.setHighlightedVenue(venue)
      this.listPanel.toggleTypeInput(false)

      this.infoPanel.hideMessages()

      this.saveHistoryState(`/map/venue/${venue.id}`, venue)
      this.currentVenue = venue
    } else {
      this.showEvent(venue.events[0], venue)
    }
  }

  showMap() {
    this._setMode('list')
    this.map.setHighlightedVenue(null)
    this.listPanel.toggleTypeInput(true)

    if (this.currentMapOverview) {
      this.map.flyTo(this.currentMapOverview.center, this.currentMapOverview.zoom)
    } else {
      this.map.zoomOut()
    }

    this.updateMode()
    this.saveHistoryState('/map')
    this.currentVenue = null
    this.currentMapOverview = null
  }

  updateMode() {
    if (this.mode == 'list' || this.mode == 'map') {
      this._setMode(this.map.isZoomWide() ? 'map' : 'list')
    }
  }

  saveMapState() {
    if (this.mode == 'map' || this.mode == 'list') {
      const center = this.map.mapbox.getCenter()
      this.currentMapOverview = {
        center: {
          latitude: center.lat,
          longitude: center.lng,
        },
        zoom: this.map.mapbox.getZoom(),
      }
    }
  }

  back() {
    if (this.mode == 'event' && this.currentVenue) {
      this.showVenue(this.currentVenue)
    } else {
      this.showMap()
    }
  }

  saveHistoryState(path, highlightLocation = null) {
    let state = {}
    
    if (path.indexOf('#') == -1) {
      if (highlightLocation) {
        path += `#${this.map.highlightZoom}/${highlightLocation.latitude}/${highlightLocation.longitude}`
      } else if (window.location.hash) {
        path += window.location.hash
      }
    }

    if (this.currentVenue) {
      state.venue = this.currentVenue
    }

    if (this.currentMapOverview) {
      state.overview = this.currentMapOverview
    }

    history.replaceState(state, undefined, path)
  }

  _setListingType(type) {
    if (this.listingType == type) return

    this.listingType = type
    document.body.dataset.list = type
    this.map.updateRenderedVenues(true)
  }

  _setMode(mode) {
    if (this.mode == mode) return

    if (this.mode) {
      document.body.classList.remove(`mode--${this.mode}`)
    }

    this.mode = mode

    if (this.mode) {
      document.body.classList.add(`mode--${this.mode}`)
      document.body.scrollTop = 0
    }

    this.map.invalidateSize()
  }
}
