/* global AtlasAPI, WorldMap, Util, Navbar, ListPanel, InfoPanel, ImageGallery, TimingCarousel, SharingModal */

class ApplicationInstance {

  constructor() {
    const map = document.getElementById('map')

    this.mode = null
    this.map = new WorldMap(map)
    this.listPanel = new ListPanel(document.getElementById('js-list-panel'))
    this.infoPanel = new InfoPanel(document.getElementById('js-info-panel'))
    this.navbar = new Navbar(document.getElementById('js-navbar'))
    this.imageGallery = new ImageGallery(document.getElementById('js-image-gallery'))
    this.timingCarousel = new TimingCarousel(document.getElementById('js-timing-carousel'))
    this.share = new SharingModal(document.getElementById('js-share'))
    this.atlas = new AtlasAPI(map.dataset.api)

    const initialEvents = JSON.parse(map.dataset.events).results
    if (initialEvents) {
      this.showList(initialEvents)

      if (map.dataset.featured == 'true') {
        this.showEvent(initialEvents[0])
      }
    }

    if (map.dataset.restricted == 'true') {
      this.map.lockBounds()
    }
  }

  showList(venues) {
    this.setMode('list')

    if (venues) {
      this.navbar.setActive(false)
      //this.listPanel.setEvents(events)
      this.listPanel.setVenues(venues)

      if (!Util.isDevice('mobile')) {
        this.toggleCollapsed(false)
      }

      //this.map.setEventMarkers(venues)
      this.map.setVenueMarkers(venues)
    }

    this.map.scaleToMax()
    this.setInteractive(true)
    this.listPanel.resetFilter()
    this.listPanel.setActiveItem(null)
    this.map.selectMarker(null)
    this.map.invalidateViewportDimensions()
    this.map.fitToMarkers()
  }

  showVenue(venue) {
    this.setMode('venue')
    this.navbar.setVenue(venue)
    this.listPanel.filterByVenue(venue)
    this.listPanel.setActiveItem(null)
    this.setInteractive(false)
    this.map.selectMarker(venue.id)
    this.map.invalidateViewportDimensions()
    this.map.zoomToVenue(venue)
  }

  showEvent(event) {
    this.wasVenueMode = Util.isMode('venue')
    this.setMode('event')
    this.listPanel.setActiveItem(event.id)
    this.infoPanel.show(event)
    this.setInteractive(false)
    this.map.selectMarker(event.venue_id)
    //this.map.invalidateViewportDimensions()
    this.map.zoomToVenue(event)
  }

  closeEvent() {
    if (this.wasVenueMode) {
      this.setMode('venue')
      this.listPanel.setActiveItem(null)
    } else {
      this.showList()
    }
  }

  setMode(mode) {
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

  setInteractive(interactive) {
    document.body.classList.toggle('map-interactive', interactive)
    this.map.setInteractive(interactive)
  }

  toggleCollapsed(collapsed) {
    const isCollapsed = document.body.classList.toggle('collapsed', collapsed)

    if (!isCollapsed) {
      this.navbar.setActive(false)
    }

    this.map.invalidateViewportDimensions()
    this.map.fitToMarkers()
  }

  loadEvents(query) {
    this.setMode('list')

    this.atlas.query(query, response => {
      if (response.status == 'success') {
        this.showList(response.results)
      } else {
        this.listPanel.showEmptyResults(response.alternatives[0])
        this.map.zoomTo(query.latitude, query.longitude)
        this.toggleCollapsed(false)
        //this.map.setEventMarkers([])
        this.map.setVenueMarkers([])
      }
    })
  }

}

document.addEventListener('DOMContentLoaded', () => {
  window.Application = new ApplicationInstance()
})
