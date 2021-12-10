/* global mapboxgl, Application, Util */
/* exported MapView */

class MapView {

  constructor(element, venue = null) {
    this.container = element
    this.mobileBreakpoint = 768
    this.desktopBreakpoint = 1100
    this.viewportPadding = 5
    this.invalidating = true
    this.loading = true
    this.highlightZoom = 16

    const config = {
      container: 'map',
      style: 'mapbox://styles/sydevadmin/ck7g6nag70rn11io09f45odkq',
      minZoom: 1,
      dragRotate: false,
      hash: true,
    }

    mapboxgl.accessToken = element.dataset.token

    if (venue) {
      config.center = [venue.longitude, venue.latitude]
      config.zoom = this.highlightZoom
    } else if (element.dataset.bounds) {
      config.bounds = JSON.parse(element.dataset.bounds)
    } else if (element.dataset.latitude && element.dataset.longitude) {
      config.center = [element.dataset.longitude, element.dataset.latitude]
      config.zoom = 10
    }

    this.mapbox = new mapboxgl.Map(config)
    this.loadControlLayers()

    this.mapbox.on('load', _event => {
      Application.atlas.getGeojson(geojson => {
        this.loadFeatureLayers(geojson)
        this.createEventHooks()
        this.invalidating = false
        this.loading = false

        if (venue) {
          this.setHighlightedVenue(venue, false)
        }
  
        //this.mapbox.showPadding = true
        this.updatePadding()
      })
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

  loadFeatureLayers(geojsonData) {
    this.venuesLayer = 'original'
    this.clusterSource = 'meditation-cluster-source'
    this.clusteredCirclesLayer = 'meditation-clusters'
    this.clusteredPointsLayer = 'meditation-points'

    this.selectedVenueSource = 'selected-venue-source'
    this.selectedVenueLayer = 'selected-venue'

    this.mapbox.addSource(this.clusterSource, {
      type: 'geojson',
      data: geojsonData,
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
        'icon-allow-overlap': true,
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
        Application.showVenue(this.parseVenue(features[0]))
      }
    })

    this.mapbox.on('click', this.clusteredCirclesLayer, event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.clusteredCirclesLayer] })
      var clusterId = features[0].properties.cluster_id
      this.mapbox.getSource(this.clusterSource).getClusterExpansionZoom(clusterId, (error, zoom) => {
        if (error) {
          console.error(error) // eslint-disable-line no-console
        } else {
          Application._setListingType('offline')
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

    this.mapbox.on('dragstart', _event => Application.navbar.setText(null))
    //this.mapbox.on('move', _event => this.updateRenderedVenues())
    this.mapbox.on('render', _event => this.updateRenderedVenues())
    this.mapbox.on('moveend', _event => this.updateRenderedVenues(true))
    this.mapbox.on('zoom', _event => Application.updateMode())
    window.addEventListener('resize', _event => this.updatePadding())
  }

  async updateRenderedVenues(allowFallback = false) {
    if (this.invalidating) return

    let isListMode = Util.isMode('list')
    let isMapMode = Util.isMode('map')
    if (!(isListMode || isMapMode)) return

    if (!this.isZoomWide()) {
      if (Application.listingType == 'online') {
        Application.atlas.getOnlineEvents(this.getCenter(), events => Application.showOnlineEvents(events))
      } else {
        this.getRenderedVenues(venues => Application.showVenues(venues, allowFallback))
      }
    }
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

  setHighlightedVenue(venue, zoomToVenue = true) {
    if (this.loading) return

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

      if (zoomToVenue) {
        this.flyTo(venue, this.highlightZoom)
      }
    } else {
      this.mapbox.getSource(this.selectedVenueSource).setData({ type: 'FeatureCollection', features: [] })
      this.mapbox.setMaxBounds(null)
    }
  }

  flyTo(location, zoom) {
    zoom = zoom || this.highlightZoom
    this.updatePadding()

    if (Util.isDevice('mobile')) {
      this.mapbox.jumpTo({
        center: [location.longitude, location.latitude],
        zoom: zoom,
      })
    } else {
      this.mapbox.flyTo({
        center: [location.longitude, location.latitude],
        zoom: zoom,
        //easing: this._easing.
      })
    }
  }

  fitTo(bounds) {
    bounds = [[bounds.west, bounds.south], [bounds.east, bounds.north]]
    this.updatePadding()
    this.mapbox.fitBounds(bounds, {
      animate: !Util.isDevice('mobile'),
    })
  }

  updatePadding() {
    this.mapbox.setPadding(this.getViewportPadding())
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
    return this.mapbox.getZoom() < 7.5
  }

  _easing(t) {
    return t < 0.5 ? (8 * t * t * t * t) : (1 - 8 * (--t) * t * t * t)
  }

  distance(point) {
    if (this.location && point) {
      return Util.distance(this.location.latitude, this.location.longitude, point.latitude, point.longitude)
    } else {
      return null
    }
  }

  getViewportPadding() {
    let padding

    if (Util.isDevice('mobile')) {
      if (Util.isMode('list')) {
        padding = { top: 80 }
      } else {
        padding = { top: 0, left: 0, right: 0, bottom: 0 }
      }
    } else if (Util.isDevice('tablet')) {
      padding = {}
    } else {
      /*
      let leftPadding

      if (Util.isMode('event')) {
        leftPadding = Application.infoPanel.container.offsetLeft + Application.infoPanel.container.offsetWidth
      } else {
        leftPadding = Application.listPanel.container.offsetLeft + Application.listPanel.container.offsetWidth
      }
      */

      padding = {
        left: 532 + this.viewportPadding,
      }
    }

    ['top', 'left', 'bottom', 'right'].forEach(side => {
      if (typeof padding[side] === 'undefined') {
        padding[side] = this.viewportPadding
      }
    })

    const debug = document.getElementById('js-debug-viewport')
    if (debug) Object.assign(debug.style, padding)

    return padding
  }

  invalidateSize() {
    if (this.loading) return

    this.invalidating = true
    this.mapbox.resize()
    this.invalidating = false
  }

}