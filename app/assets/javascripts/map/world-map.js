/* global L, Application, Util */
/* exported WorldMap */

class WorldMap {

  constructor(element) {
    this.container = element
    
    this.leaflet = L.map(element, { zoomControl: false })
    this.markers = {}

    this.refreshButton = document.getElementById('js-refresh')
    this.refreshButton.addEventListener('click', () => this.refresh())
    this.refreshDisabled = true

    this.zoomPadding = 40
    this.minHeight = 174
    this.maxHeight = window.innerHeight - 200
    this.currentHeight = this.maxHeight
    this.container.style = `max-height: ${this.currentHeight}`
    
    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 18,
      id: 'mapbox.streets',
      accessToken: element.dataset.token,
    }).addTo(this.leaflet)

    this.markersGroup = L.markerClusterGroup({
      spiderfyOnMaxZoom: false,
      showCoverageOnHover: false,
    }).addTo(this.leaflet)

    this.markersGroup.on('click', event => Application.setState({ venue: event.layer.options.venue }))

    this.normalIcon = L.icon({
      iconUrl: '/markers/default.png',
      shadowUrl: '/markers/shadow.png',
      iconSize: [24, 30.4],
      shadowSize: [20.6, 11.8],
      iconAnchor: [12, 30.4],
      shadowAnchor: [1.3, 11.8],
    })

    this.selectedIcon = L.icon({
      iconUrl: '/markers/selected.png',
      shadowUrl: '/markers/shadow.png',
      iconSize: [24, 30.4],
      shadowSize: [20.6, 11.8],
      iconAnchor: [12, 30.4],
      shadowAnchor: [1.3, 11.8],
    })

    this.targetIcon = L.icon({
      iconUrl: '/markers/target.png',
      shadowUrl: '/markers/shadow.png',
      iconSize: [24, 30.4],
      shadowSize: [20.6, 11.8],
      iconAnchor: [12, 30.4],
      shadowAnchor: [1.3, 11.8],
    })

    window.addEventListener('wheel', event => this.scaleByScroll(event), { passive: false })
    document.getElementById('js-zoom-in').addEventListener('click', () => this.zoom(+1))
    document.getElementById('js-zoom-out').addEventListener('click', () => this.zoom(-1))

    this.leaflet.on('zoomstart', () => this.setRefreshHidden(false))
    this.leaflet.on('movestart', () => this.setRefreshHidden(false))
    this.leaflet.on('resize', () => this.invalidateViewportDimensions())
    this.leaflet.on('zoomend', () => this.invalidateViewportDimensions())
    this.leaflet.on('moveend', () => this.invalidateViewportDimensions())
    this.invalidateViewportDimensions()
  }

  setInteractive(interactive) {
    this.setRefreshDisabled(!interactive)

    this.leaflet._handlers.forEach(function(handler) {
      if (interactive) {
        handler.enable()
      } else {
        handler.disable()
      }
    })
  }

  // ===== MARKER MANIUPLATION ===== //

  setVenueMarkers(venues) {
    this.markersGroup.clearLayers()

    if (venues.length > 0) {
      for (let i = 0; i < venues.length; i++) {
        if (venues[i].events.length > 0) {
          this.addVenueMarker(venues[i])
        }
      }
    }
  }

  addVenueMarker(venue) {
    const marker = L.marker([venue.latitude, venue.longitude], { venue: venue, icon: this.normalIcon })
    this.markers[venue.id] = marker
    marker.addTo(this.markersGroup)
  }

  setTargetMarker(location) {
    if (location) {
      if (!this.targetMarker) {
        this.targetMarker = L.marker([location.latitude, location.longitude], { icon: this.targetIcon })
      } else {
        this.targetMarker.setLatLng([location.latitude, location.longitude])
      }

      this.targetMarker.addTo(this.leaflet)
    } else if (this.targetMarker) {
      this.leaflet.removeLayer(this.targetMarker)
    }
  }

  clearMarkers() {
    this.markersGroup.clearLayers()
    this.markers = []
  }

  // ===== SCROLL RESIZING ===== //

  scaleByScroll(event) {
    if (!Util.isDevice('mobile')) return

    this.currentHeight = this.container.offsetHeight
    if (event.deltaY < 0 && window.scrollY <= 0) event.preventDefault()
    if (event.deltaY == 0 || window.scrollY > 0) return
    if (event.deltaY < 0 && this.currentHeight >= this.maxHeight) return
    if (event.deltaY > 0 && this.currentHeight <= this.minHeight) return
    
    this.currentHeight = this.currentHeight - event.deltaY
    this.currentHeight = Math.min(Math.max(this.currentHeight, this.minHeight), this.maxHeight)
    this.container.style = `max-height: ${this.currentHeight}`
    this.setRefreshHidden(this.currentHeight < this.maxHeight)
    Application.setInteractive(this.currentHeight >= this.maxHeight)
    event.preventDefault()
  }

  scaleToMax() {
    this.container.style = `max-height: ${this.maxHeight}`
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
      maxZoom: 8,
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

  selectMarker(marker_or_id) {
    const marker = (typeof(marker_or_id) === 'number' ? this.markers[marker_or_id] : marker_or_id)
      
    if (this.selectedMarker) {
      this.selectedMarker.setIcon(this.normalIcon)
    }

    this.selectedMarker = marker

    if (this.selectedMarker) {
      this.selectedMarker.setIcon(this.selectedIcon)
    }
  }

  refresh() {
    const bounds = this.getViewportBounds()
    const buffer = 1.1
    bounds.north *= buffer
    bounds.south *= buffer
    bounds.east *= buffer
    bounds.west *= buffer

    Application.loadEvents(bounds)
    Application.navbar.select(null)
    this.setRefreshDisabled(true)
  }

  setRefreshDisabled(disabled) {
    this.refreshDisabled = disabled

    if (disabled) {
      this.refreshButton.classList.add('refresh-control__button--hidden')
    }
  }

  setRefreshHidden(hidden) {
    if (this.refreshDisabled) return
    this.refreshButton.classList.toggle('refresh-control__button--hidden', hidden)
  }

  // ===== UTILITY ===== //

  invalidateViewportDimensions() {
    let result

    if (Util.isDevice('mobile')) {
      result = {
        top: this.zoomPadding / 2,
        bottom: this.zoomPadding / 2,
        left: this.zoomPadding / 2,
        right: this.zoomPadding / 2,
      }

      if (Util.isMode('list')) {
        result.top = 124 + this.zoomPadding / 2
      }
    } else {
      result = {
        top: this.refreshButton.getBoundingClientRect().bottom + this.zoomPadding,
        bottom: this.zoomPadding,
        left: this.zoomPadding,
        right: this.zoomPadding,
      }

      if (Util.isDevice('desktop')) {
        result.left = 531 + this.zoomPadding
      }
    }

    result.width = this.leaflet._container.clientWidth - result.left - result.right
    result.height = this.leaflet._container.clientHeight - result.top - result.bottom
    result.x = result.left + result.width / 2
    result.y = result.top + result.height / 2
    this.viewport = result
    this.maxHeight = window.innerHeight - 200

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
      latitude: center.lat.toFixed(6),
      longitude: center.lng.toFixed(6),
    }
  }

  // ===== DEBUGGING ===== //

  updateViewportBox() {
    document.getElementById('js-debug-viewport').style = `top: ${this.viewport.top}; bottom: ${this.viewport.bottom}; left: ${this.viewport.left}; right: ${this.viewport.right}`
    document.getElementById('js-debug-viewport-center').style = `top: ${this.viewport.y}; left: ${this.viewport.x}`
  }

}