/* global mapboxgl, Application, Util */
/* exported MapView */

class MapView {

  constructor(element, onLoadCallback) {
    this.container = element
    this.venuesLayer = 'original'
    this.mobileBreakpoint = 768
    this.desktopBreakpoint = 1100
    this.viewportPadding = 0

    const state = JSON.parse(this.container.dataset.state)
    const config = {
      container: 'map',
      style: 'mapbox://styles/sydevadmin/ck7g6nag70rn11io09f45odkq',
      minZoom: 1,
      dragRotate: false,
    }

    mapboxgl.accessToken = element.dataset.token
    if (state.longitude && state.latitude) {
      config.center = [state.longitude, state.latitude]
    }

    if (state.zoom) {
      config.zoom = state.zoom
    }

    this.mapbox = new mapboxgl.Map(config)
    this.mapbox.addControl(new mapboxgl.NavigationControl({ showCompass: false }))

    const geolocater = new mapboxgl.GeolocateControl()
    this.mapbox.addControl(geolocater)
    geolocater.on('geolocate', event => {
      this.setLocation(event.coords, true)
    })

    this.mapbox.on('load', _event => {
      onLoadCallback()
    })

    this.mapbox.on('click', event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.venuesLayer] })
      if (features.length > 0) {
        Application.setState({ venue: this.parseVenue(features[0]) })
      }
    })
  
    // Indicate that the symbols are clickable by changing the cursor style to 'pointer'.
    this.mapbox.on('mousemove', event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.venuesLayer] })
      this.mapbox.getCanvas().style.cursor = features.length ? 'pointer' : ''
    })

    this.mapbox.on('moveend', _event => {
      if (Util.isMode('list')) {
        Application.showVenues(this.getRenderedVenues())
      }
    })
  }

  getRenderedVenues() {
    const features = this.mapbox.queryRenderedFeatures({ layers: [this.venuesLayer] })
    const featureKeys = {}
    const uniqueFeatures = features.filter(feature => {
      if (featureKeys[feature.properties.id]) {
        return false
      } else {
        featureKeys[feature.properties.id] = true
        return true
      }
    })
    
    return uniqueFeatures.map(feature => this.parseVenue(feature))
  }

  setHighlightedVenue(venue) {
    if (!this.selectedMarker) {
      const icon = document.createElement('DIV')
      icon.className = 'mapboxgl-marker--selected'
      this.selectedMarker = new mapboxgl.Marker({ element: icon, offset: [0, -16] })
    }

    if (venue) {
      this.selectedMarker.setLngLat([venue.longitude, venue.latitude]).addTo(this.mapbox)
      this.flyTo(venue, 16)
    } else {
      this.selectedMarker.remove()
    }
  }

  flyTo(location, zoom) {
    this.mapbox.flyTo({
      center: [location.longitude, location.latitude],
      offset: this.getViewportCenterOffset(),
      zoom: zoom,
      //easing: this._easing.
    })
  }

  fitTo(bounds) {
    this.mapbox.fitBounds([[bounds.west, bounds.south], [bounds.east, bounds.north]], {
      padding: this.getViewportPadding(),
      easing: this._easing,
    })
  }

  getCenter() {
    const center = this.mapbox.getCenter()
    return { latitude: center.lat, longitude: center.lng }
  }

  setLocation(location, disableMarker = false) {
    this.location = location

    if (!this.locationMarker) {
      this.locationMarker = new mapboxgl.Marker()
    }

    if (disableMarker || location == null) {
      this.locationMarker.remove()
    } else {
      this.locationMarker.setLngLat([location.longitude, location.latitude]).addTo(this.mapbox)
    }
  }

  setInteractive(interactive) {
    if (!Util.isDevice('mobile')) {
      // Never disable interaction on tablet and desktop
      interactive = true
    }
    
    const handlers = ['scrollZoom', 'boxZoom', 'dragRotate', 'dragPan', 'keyboard', 'doubleClickZoom', 'doubleClickZoom']
    handlers.forEach(handler => {
      this.mapbox[handler][interactive ? 'enable' : 'disable']()
    })
  }

  parseVenue(feature) {
    const venue = feature.properties
    venue.events = JSON.parse(venue.events)
    return venue
  }

  zoomOut() {
    this.mapbox.zoomTo(10)
  }

  _easing(t) {
    return t < 0.5 ? (8 * t * t * t * t) : (1 - 8 * (--t) * t * t * t)
  }

  distance(point) {
    if (this.location && point) {
      return Util.distance(this.location.latitude, this.location.longitude, point.latitude, point.longitude, 'K')
    } else {
      return null
    }
  }

  getViewportPadding() {
    if (Util.isDevice('mobile')) {
      if (Util.isMode('list')) {
        const topPadding = Application.navbar.container.offsetTop + Application.listPanel.container.offsetHeight
        return {
          top: topPadding + this.viewportPadding * 2,
          bottom: this.viewportPadding,
          right: this.viewportPadding,
          left: this.viewportPadding,
        }
      } else {
        return 0
      }
    } else if (Util.isDevice('tablet')) {
      return this.viewportPadding
    } else {
      const leftPadding = Application.listPanel.container.offsetLeft + Application.listPanel.container.offsetWidth
      return {
        top: this.viewportPadding,
        bottom: this.viewportPadding,
        right: this.viewportPadding,
        left: leftPadding + this.viewportPadding,
      }
    }
  }

  getViewportCenterOffset() {
    let viewportPadding = this.getViewportPadding()
    if (typeof viewportPadding === 'number') {
      viewportPadding = { top: viewportPadding, left: viewportPadding }
    }

    const left = Math.min(0, viewportPadding.left - this.viewportPadding)
    const top = Math.min(0, viewportPadding.top - this.viewportPadding)
    return [left, top]
  }

  invalidateSize() {
    this.mapbox.resize()
  }

}