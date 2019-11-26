/* global L, Application */
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

    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 18,
      id: 'mapbox.streets',
      accessToken: element.dataset.token,
    }).addTo(this.leaflet)

    L.control.zoom({
      position: 'topright',
      zoomInText: '',
      zoomOutText: '',
      zoomInTitle: 'Zoom in',
      zoomOutTitle: 'Zoom out',
    }).addTo(this.leaflet)

    this.markersGroup = L.featureGroup().addTo(this.leaflet)
    /*this.markersGroup = L.markerClusterGroup({
      spiderfyOnMaxZoom: false,
      showCoverageOnHover: false,
      singleMarkerMode: true,
    }).addTo(this.leaflet)*/
    this.markersGroup.on('click', event => this.selectMarker(event.layer))

    this.leaflet.on('resize', () => this.setRefreshHidden(false))
    this.leaflet.on('zoomstart', () => this.setRefreshHidden(false))
    this.leaflet.on('movestart', () => this.setRefreshHidden(false))
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

  fitToMarkers() {
    const bounds = this.markersGroup.getBounds()
    const padding = this.computeViewportPadding()
    this.leaflet.fitBounds(bounds, {
      paddingTopLeft: [padding.left, padding.top],
      paddingBottomRight: [padding.right, padding.bottom],
      maxZoom: 14,
    })
  }

  zoomToEvents(events) {
    if (events.length == 0) return

    const bounds = L.latLngBounds()
    const padding = this.computeViewportPadding()

    events.forEach(event => {
      bounds.extend(L.latLng(event.latitude, event.longitude))
    })

    this.leaflet.fitBounds(bounds, {
      paddingTopLeft: [padding.left, padding.top],
      paddingBottomRight: [padding.right, padding.bottom],
      maxZoom: 14,
    })
  }

  zoomToVenue(venue) {
    const padding = this.computeViewportPadding()
    this.leaflet.fitBounds(L.latLngBounds([[venue.latitude, venue.longitude], [venue.latitude, venue.longitude]]), {
      paddingTopLeft: [padding.left, padding.top],
      paddingBottomRight: [padding.right, padding.bottom],
      maxZoom: 15,
    })
  }

  lockBounds() {
    this.leaflet.setMaxBounds(this.leaflet.getBounds())
    this.leaflet.setMinZoom(this.leaflet.getZoom())
  }

  // ===== INTERACTION ===== //

  selectMarker(marker) {
    const venue = marker.options.venue
    this.zoomToVenue(venue)
    Application.panels.listing.filterByVenue(venue)
  }

  refresh() {
    const bounds = this.computeUseableLatLngViewport()
    Application.loadEvents(bounds)
    this.setRefreshHidden(true)
  }

  setRefreshHidden(hidden) {
    if (this.refreshInProgress) return
    this.refreshButton.classList.toggle('refresh__button--hidden', hidden)
  }

  // ===== UTILITY ===== //

  computeViewportPadding(mode = null) {
    let result = {
      top: this.refreshButton.getBoundingClientRect().bottom + this.zoomPadding,
      bottom: this.zoomPadding,
      left: this.panels.getBoundingClientRect().right + this.zoomPadding,
      right: this.zoomPadding,
    }

    if (window.innerWidth < 768) {
      result.left = this.zoomPadding
      result.top = this.searchBox.getBoundingClientRect().bottom + this.zoomPadding
      //result.bottom = this.panels.getBoundingClientRect().top + this.zoomPadding
    }

    if (mode == 'percent') {
      // As a percentage of the map's viewport size
      const size = this.leaflet.getSize()
      result = {
        top: result.top / size.y,
        bottom: result.bottom / size.y,
        left: result.left / size.x,
        right: result.right / size.x,
      }
    }

    return result
  }

  computeUseableLatLngViewport() {
    // We need to compute the latlng bounds of the map, but only the parts which are not covered by controls.
    // This needs to roughly mirror the zoomToEvents method, to avoid unnecessary zooming.
    const percentPadding = this.computeViewportPadding('percent')
    const bounds = this.leaflet.getBounds()
    const boundsDimensions = {
      latitudes: Math.abs(bounds.getNorth() - bounds.getSouth()),
      longitudes: Math.abs(bounds.getWest() - bounds.getEast()),
    }
    
    const result = {
      north: bounds.getNorth() - (boundsDimensions.latitudes * percentPadding.top),
      south: bounds.getSouth() + (boundsDimensions.latitudes * percentPadding.bottom),
      west: bounds.getWest() - (boundsDimensions.longitudes * percentPadding.left),
      east: bounds.getEast() + (boundsDimensions.longitudes * percentPadding.right),
    }

    return {
      north: result.north.toFixed(6),
      south: result.south.toFixed(6),
      west: result.west.toFixed(6),
      east: result.east.toFixed(6),
    }
  }

}