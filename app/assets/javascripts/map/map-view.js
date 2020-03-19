/* global mapboxgl, Application, Util */
/* exported MapView */

class MapView {

  constructor(element, onLoadCallback) {
    this.container = element
    this.venuesLayer = 'original'
    const state = JSON.parse(this.container.dataset.state)
    const config = {
      container: 'map',
      style: 'mapbox://styles/sydevadmin/ck7g6nag70rn11io09f45odkq',
      minZoom: 1,
      dragRotate: false
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
    if (!this.targetMarker) {
      const icon = document.createElement('DIV')
      icon.className = 'mapboxgl-marker--selected'
      this.targetMarker = new mapboxgl.Marker({ element: icon, offset: [0, -16] })
    }

    if (venue) {
      this.targetMarker.setLngLat([venue.longitude, venue.latitude]).addTo(this.mapbox)
      this.flyTo(venue, 16)
    } else {
      this.targetMarker.remove()
    }
  }

  flyTo(location, zoom) {
    this.mapbox.flyTo({ center: [location.longitude, location.latitude], zoom: zoom, easing: this._easing })
  }

  fitTo(bounds) {
    this.mapbox.fitBounds([[bounds.west, bounds.south], [bounds.east, bounds.north]], { easing: this._easing })
  }

  getCenter() {
    const center = this.mapbox.getCenter()
    return { latitude: center.lat, longitude: center.lng }
  }

  setInteractive(interactive) {
    const handlers = ['scrollZoom', 'boxZoom', 'dragRotate', 'dragPan', 'keyboard', 'doubleClickZoom', 'doubleClickZoom']
    handlers.forEach(handler => {
      this.mapbox[handler][interactive ? 'enable' : 'disable']()
    })
  }

  parseVenue(feature) {
    const venue = feature.properties
    venue.events = JSON.parse(venue.events)
    venue.latitude = feature.geometry.coordinates[1]
    venue.longitude = feature.geometry.coordinates[0]
    return venue
  }

  zoomOut() {
    this.mapbox.zoomTo(10)
  }

  _easing(t) {
    return t < 0.5 ? (8 * t * t * t * t) : (1 - 8 * (--t) * t * t * t)
  }

}