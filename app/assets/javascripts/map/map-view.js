/* global mapboxgl, Application, Util */
/* exported MapView */

class MapView {

  constructor(element, onLoadCallback) {
    this.container = element
    this.mobileBreakpoint = 768
    this.desktopBreakpoint = 1100
    this.viewportPadding = 0
    this.invalidating = true

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
    this.loadControlLayers()

    this.mapbox.on('load', _event => {
      this.loadFeatureLayers()
      this.createEventHooks()
      onLoadCallback()
      this.invalidating = false
    })
  }

  loadControlLayers() {
    this.mapbox.addControl(new mapboxgl.NavigationControl({ showCompass: false }))

    const geolocater = new mapboxgl.GeolocateControl()
    this.mapbox.addControl(geolocater)

    geolocater.on('geolocate', event => {
      this.setLocation(event.coords, true)
    })
  }

  loadFeatureLayers() {
    this.venuesLayer = 'original'
    this.clusterSource = 'meditation-cluster-source'
    this.clusteredCirclesLayer = 'meditation-clusters'
    this.clusteredPointsLayer = 'meditation-points'

    this.selectedVenueSource = 'selected-venue-source'
    this.selectedVenueLayer = 'selected-venue'

    this.mapbox.addSource(this.clusterSource, {
      type: 'geojson',
      data: this.container.dataset.geojson,
      cluster: true,
      clusterMaxZoom: 12, // Max zoom to cluster points on
      clusterRadius: 50, // Radius of each cluster when clustering points
    })

    this.mapbox.addLayer({
      id: this.clusteredCirclesLayer,
      type: 'symbol',
      source: this.clusterSource,
      filter: ['has', 'point_count'],
      layout: {
        'icon-image': 'cluster-1',
        'text-field': '{point_count_abbreviated}',
        'text-font': ['DIN Offc Pro Bold', 'Arial Unicode MS Bold'],
        'text-size': 12,
      },
      paint: {
        'text-color': '#FFFFFF',
      },
    })

    this.mapbox.addLayer({
      id: this.clusteredPointsLayer,
      type: 'symbol',
      source: this.clusterSource,
      filter: ['!', ['has', 'point_count']],
      layout: {
        'icon-image': 'marker_default',
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })

    this.mapbox.addSource(this.selectedVenueSource, { type: 'geojson', data: null })
    this.mapbox.addLayer({
      id: this.selectedVenueLayer,
      type: 'symbol',
      source: this.selectedVenueSource,
      filter: ['!', ['has', 'point_count']],
      layout: {
        'icon-image': 'marker_selected',
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })
  }

  createEventHooks() {
    this.mapbox.on('click', event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.venuesLayer, this.clusteredPointsLayer] })
      if (features.length > 0) {
        Application.setState({ venue: this.parseVenue(features[0]) })
      }
    })

    this.mapbox.on('click', this.clusteredCirclesLayer, event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.clusteredCirclesLayer] })
      var clusterId = features[0].properties.cluster_id
      this.mapbox.getSource(this.clusterSource).getClusterExpansionZoom(clusterId, (error, zoom) => {
        if (error) {
          console.error(error) // eslint-disable-line no-console
        } else {
          this.mapbox.easeTo({
            center: features[0].geometry.coordinates,
            zoom: zoom + 1,
            duration: 500,
          })
        }
      })
    })
  
    // Indicate that the symbols are clickable by changing the cursor style to 'pointer'.
    this.mapbox.on('mousemove', event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.venuesLayer, this.clusteredPointsLayer, this.clusteredCirclesLayer] })
      this.mapbox.getCanvas().style.cursor = features.length ? 'pointer' : ''
    })

    this.mapbox.on('move', _event => {
      if (!this.invalidating && (Util.isMode('list') || Util.isMode('map'))) {
        const center = this.getCenter()

        Application.replaceListState({
          latitude: center.latitude.toFixed(6),
          longitude: center.longitude.toFixed(6),
          zoom: this.mapbox.getZoom().toFixed(2)
        }, this.isZoomWide(), false)
      }
    })

    this.mapbox.on('moveend', _event => {
      if (!this.invalidating && (Util.isMode('list') || Util.isMode('map'))) {
        const center = this.getCenter()
        this.getRenderedVenues(venues => Application.showVenues(venues))

        Application.replaceListState({
          latitude: center.latitude.toFixed(6),
          longitude: center.longitude.toFixed(6),
          zoom: this.mapbox.getZoom().toFixed(2)
        }, this.isZoomWide())
      }
    })
  }

  getRenderedVenues(callback) {
    const features = this.mapbox.queryRenderedFeatures({ layers: [this.clusteredPointsLayer] })
    const clusters = this.mapbox.queryRenderedFeatures({ layers: [this.clusteredCirclesLayer] })

    if (clusters.length > 0) {
      this.collectClusterFeatures(clusters, clusterFeatures => {
        const uniqueFeatures = this.getUniqueFeatures(features.concat(clusterFeatures))
        const result = uniqueFeatures.map(feature => this.parseVenue(feature))
        callback(result)
      })
    } else {
      const uniqueFeatures = this.getUniqueFeatures(features)
      const result = uniqueFeatures.map(feature => this.parseVenue(feature))
      callback(result)
    }
  }

  getUniqueFeatures(features) {
    const featureKeys = {}
    return features.filter(feature => {
      if (featureKeys[feature.properties.id]) {
        return false
      } else {
        featureKeys[feature.properties.id] = true
        return true
      }
    })
  }

  collectClusterFeatures(clusters, callback) {
    const clusterData = this.mapbox.getSource(this.clusterSource)
    let results = []
    let waitingForSources = clusters.length
    this.tempClusterFeatures = []

    clusters.forEach(cluster => {
      clusterData.getClusterLeaves(cluster.properties.cluster_id, 100, 0, (error, features) => {
        if (error) {
          console.error(error) // eslint-disable-line no-console
        } else {
          results = results.concat(features)
        }

        waitingForSources--

        if (waitingForSources <= 0) {
          callback(results)
        }
      })
    })
  }

  setHighlightedVenue(venue) {
    if (venue) {
      this.mapbox.getSource(this.selectedVenueSource).setData({
        type: 'FeatureCollection',
        features: [{
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [venue.longitude, venue.latitude]
          },
        }]
      })

      if (Util.isDevice('mobile')) {
        const width = 0.25
        const height = width * (this.container.offsetHeight / window.innerWidth)
        const bounds = new mapboxgl.LngLatBounds([
          [
            venue.longitude - width / 2.0,
            venue.latitude - height / 2.0,
          ], [
            venue.longitude + width / 2.0,
            venue.latitude + height / 2.0,
          ]
        ])
        this.mapbox.setMaxBounds(bounds)
      }

      this.flyTo(venue, 16)
    } else {
      this.mapbox.getSource(this.selectedVenueSource).setData({ type: 'FeatureCollection', features: [] })
      this.mapbox.setMaxBounds(null)
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

  parseVenue(feature) {
    const venue = feature.properties
    if (typeof venue.events === 'string') {
      venue.events = JSON.parse(venue.events)
    }
    return venue
  }

  zoomOut() {
    this.mapbox.zoomTo(10)
  }

  isZoomWide() {
    return this.mapbox.getZoom() < 8
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
    this.invalidating = true
    this.mapbox.resize()
    this.invalidating = false
  }

}