/* global L, Application, Util */
/* exported WorldMap */

class WorldMap {

  constructor(element) {
    this.leaflet = L.map(element, { zoomControl: false })
    this.markers = {}

    this.panels = document.getElementById('js-panels')
    this.searchBox = document.getElementById('js-search')
    this.refreshButton = document.getElementById('js-refresh')
    this.refreshButton.addEventListener('click', () => this.refresh())
    this.refreshInProgress = false

    this.zoomPadding = 40

    //L.tileLayer('https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}', {
    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 18,
      id: 'mapbox.streets',
      accessToken: element.dataset.token,
    }).addTo(this.leaflet)

    //this.markersGroup = L.featureGroup().addTo(this.leaflet)
    this.markersGroup = L.markerClusterGroup({
      spiderfyOnMaxZoom: false,
      showCoverageOnHover: false,
      //singleMarkerMode: true,
    }).addTo(this.leaflet)
    this.markersGroup.on('click', event => this.selectMarker(event.layer))

    document.getElementById('js-zoom-in').addEventListener('click', () => this.zoom(+1))
    document.getElementById('js-zoom-out').addEventListener('click', () => this.zoom(-1))

    this.leaflet.on('zoomstart', () => this.setRefreshHidden(false))
    this.leaflet.on('movestart', () => this.setRefreshHidden(false))
    this.leaflet.on('resize', () => {
      this.setRefreshHidden(false)
      this.invalidateViewportDimensions()
      this.fitToMarkers()
    })

    this.invalidateViewportDimensions()
  }

  // ===== MARKER MANIUPLATION ===== //

  setEventMarkers(events) {
    this.markersGroup.clearLayers()

    if (events.length > 0) {
      for (let i = 0; i < events.length; i++) {
        const event = events[i]

        this.addVenueMarker({
          id: event.venue_id,
          latitude: event.latitude,
          longitude: event.longitude,
          address: event.address,
        })
      }

      this.fitToMarkers()
    }
  }

  addVenueMarker(venue) {
    const marker = L.marker([venue.latitude, venue.longitude], { venue: venue })
    this.markers[venue.id] = marker
    marker.addTo(this.markersGroup)
  }

  clearMarkers() {
    this.markersGroup.clearLayers()
    this.markers = []
  }

  // ===== ZOOM MANIPULATION ===== //

  zoom(adjustment) {
    const minZoom = this.leaflet.getMinZoom()
    const maxZoom = this.leaflet.getMaxZoom()
    const currentZoom = this.leaflet.getZoom()
    const newZoom = Math.max(minZoom, Math.min(currentZoom + adjustment, maxZoom))

    if (newZoom != currentZoom) {
      const center = L.point(this.viewport.x, this.viewport.y)
      this.leaflet.setZoomAround(center, newZoom)
    }
  }

  fitToMarkers() {
    if (this.markersGroup.getLayers().length == 0) return
    const bounds = this.markersGroup.getBounds()
    this.leaflet.fitBounds(bounds, {
      paddingTopLeft: [this.viewport.left, this.viewport.top],
      paddingBottomRight: [this.viewport.right, this.viewport.bottom],
      maxZoom: 14,
    })
  }

  zoomToEvents(events) {
    if (events.length == 0) return

    const bounds = L.latLngBounds()

    events.forEach(event => {
      bounds.extend(L.latLng(event.latitude, event.longitude))
    })

    this.leaflet.fitBounds(bounds, {
      paddingTopLeft: [this.viewport.left, this.viewport.top],
      paddingBottomRight: [this.viewport.right, this.viewport.bottom],
      maxZoom: 14,
    })
  }

  zoomToVenue(venue) {
    this.zoomTo(venue.latitude, venue.longitude, 15)
  }

  zoomTo(latitude, longitude, maxZoom = 10) {
    this.leaflet.fitBounds(L.latLngBounds([[latitude, longitude], [latitude, longitude]]), {
      paddingTopLeft: [this.viewport.left, this.viewport.top],
      paddingBottomRight: [this.viewport.right, this.viewport.bottom],
      maxZoom: maxZoom,
    })
  }

  lockBounds() {
    this.leaflet.setMaxBounds(this.leaflet.getBounds())
    this.leaflet.setMinZoom(this.leaflet.getZoom())
  }

  // ===== INTERACTION ===== //

  selectMarker(marker) {
    const venue = marker.options.venue
    Application.search.setActive(false)
    Application.toggleCollapsed(false)
    Application.panels.listing.filterByVenue(venue)
    this.zoomToVenue(venue)
  }

  refresh() {
    const bounds = this.getViewportBounds()
    Application.loadEvents(bounds)
    this.setRefreshHidden(true)
  }

  setRefreshHidden(hidden) {
    if (this.refreshInProgress) return
    this.refreshButton.classList.toggle('refresh__button--hidden', hidden)
  }

  // ===== UTILITY ===== //

  invalidatePanels() {
    this.invalidateViewportDimensions()
    this.fitToMarkers()
  }

  invalidateViewportDimensions() {
    let result

    if (Util.isMobile()) {
      result = {
        top: this.zoomPadding / 2,
        bottom: (window.innerHeight - 210) + this.zoomPadding / 2,
        left: this.zoomPadding / 2,
        right: this.zoomPadding / 2,
      }

      if (Util.isCollapsed()) {
        result.top = 124 + this.zoomPadding / 2
        result.bottom = 221 + this.zoomPadding / 2
      }
    } else {
      result = {
        top: this.refreshButton.getBoundingClientRect().bottom + this.zoomPadding,
        bottom: this.zoomPadding,
        left: this.panels.getBoundingClientRect().right + this.zoomPadding,
        right: this.zoomPadding,
      }
    }

    result.width = this.leaflet._container.clientWidth - result.left - result.right
    result.height = this.leaflet._container.clientHeight - result.top - result.bottom
    result.x = result.left + result.width / 2
    result.y = result.top + result.height / 2
    this.viewport = result

    this.updateViewportBox()
    return result
  }

  getViewportBounds() {
    // We need to compute the latlng bounds of the map, but only the parts which are not covered by controls.
    const size = this.leaflet.getSize()
    const percentPadding = {
      top: this.viewport.top / size.y,
      bottom: this.viewport.bottom / size.y,
      left: this.viewport.left / size.x,
      right: this.viewport.right / size.x,
    }

    const bounds = this.leaflet.getBounds()
    const boundsDimensions = {
      latitudes: Math.abs(bounds.getNorth() - bounds.getSouth()),
      longitudes: Math.abs(bounds.getWest() - bounds.getEast()),
    }
    
    const result = {
      north: bounds.getNorth() - (boundsDimensions.latitudes * percentPadding.top),
      south: bounds.getSouth() + (boundsDimensions.latitudes * percentPadding.bottom),
      west: bounds.getWest() + (boundsDimensions.longitudes * percentPadding.left),
      east: bounds.getEast() - (boundsDimensions.longitudes * percentPadding.right),
    }

    const center = L.latLngBounds([
      [result.north, result.west],
      [result.south, result.east]
    ]).getCenter()

    return {
      north: result.north.toFixed(6),
      south: result.south.toFixed(6),
      west: result.west.toFixed(6),
      east: result.east.toFixed(6),
      latitude: center.lat,
      longitude: center.lng,
    }
  }

  // ===== DEBUGGING ===== //

  updateViewportBox() {
    document.getElementById('js-debug-viewport').style = `top: ${this.viewport.top}; bottom: ${this.viewport.bottom}; left: ${this.viewport.left}; right: ${this.viewport.right}`
    document.getElementById('js-debug-viewport-center').style = `top: ${this.viewport.y}; left: ${this.viewport.x}`
  }

}