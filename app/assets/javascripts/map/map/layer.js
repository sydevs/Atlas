/* exported AbstractMapLayer */
/* global m, App */

class AbstractMapLayer {

  // Public variables
  visible = false

  // Protected variables
  _mapbox
  _layers = {}
  _sources = {}

  // Private variables
  #config
  #loading = true

  // Getters
  get id() {
    return this.#config.id
  }

  get loading() {
    return this.#loading
  }

  constructor(mapbox, config) {
    config = Object.assign({
      clusters: {},
      points: {},
      selection: {},
      fetchGeojson: Promise.resolve(null)
    }, config)

    this.#config = config
    this._mapbox = mapbox
    this._sources = {
      locations: `${config.id}-locations`,
      selection: `${config.id}-selection`,
    }

    this._layers = {
      points: `${config.id}-points`,
      clusters: `${config.id}-clusters`,
      selection: `${config.id}-selection`,
    }


    // Setup config
    this.#config.clusters = {
      ...{
        'icon-allow-overlap': true,
        'icon-ignore-placement': true,
        'icon-image': 'cluster',
        'text-field': '{point_count_abbreviated}',
        'text-font': ['DIN Offc Pro Bold', 'Arial Unicode MS Bold'],
        'text-size': 12,
      },
      ...this.#config.clusters,
    }

    this.#config.points = {
      ...{
        'icon-ignore-placement': true,
        'icon-image': 'point',
        'text-font': ['DIN Offc Pro Bold', 'Arial Unicode MS Bold'],
        'text-size': 12,
      },
      ...this.#config.points,
    }

    this.#config.selection = {
      ...this.#config.points,
      ...{
        'icon-image': 'selected',
      },
      ...this.#config.selection,
    }

    this._setupHooks()
  }

  load() {
    this.#loading = true

    return this.#config.fetchGeojson.then(geojson => {
      this.#loadSublayers(geojson)
      this.#loading = false
    })
  }

  #loadSublayers(geojson) {
    // Create sources
    this._mapbox.addSource(this._sources.locations, {
      type: 'geojson',
      data: geojson,
      cluster: true,
      clusterMaxZoom: this.#config.selectionZoom || 12, // Max zoom to cluster points on
      clusterRadius: 50, // Radius of each cluster when clustering points
    })

    this._mapbox.addSource(this._sources.selection, {
      type: 'geojson',
      data: null,
    })

    // Create layers
    this._mapbox.addLayer({
      id: this._layers.clusters,
      type: 'symbol',
      source: this._sources.locations,
      filter: ['has', 'point_count'],
      layout: this.#config.clusters,
      paint: {
        'text-color': '#FFFFFF',
      },
    })

    this._mapbox.addLayer({
      id: this._layers.points,
      type: 'symbol',
      source: this._sources.locations,
      filter: ['!', ['has', 'point_count']],
      layout: this.#config.points,
      paint: {
        'text-color': '#FFFFFF',
      },
    })

    this._mapbox.addLayer({
      id: this._layers.selection,
      type: 'symbol',
      source: this._sources.selection,
      layout: this.#config.selection,
      minzoom: this.#config.selectionZoom || 12,
      paint: {
        'text-color': '#FFFFFF',
      },
    })
  }

  _setupHooks() {
    this._mapbox.on('click', this._layers.points, event => {
      let features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.points] })
      if (features.length < 1) return

      let location = AtlasApp.data.parse(features[0].properties)
      this._gotoLocation(location)
    })

    this._mapbox.on('click', this._layers.clusters, event => {
      const features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.clusters] })
      const clusterId = features[0].properties.cluster_id
      const source = this._mapbox.getSource(this._sources.locations)

      source.getClusterExpansionZoom(clusterId, (error, zoom) => {
        if (error) {
          console.error(error) // eslint-disable-line no-console
        } else {
          this._mapbox.easeTo({
            center: features[0].geometry.coordinates,
            zoom: zoom + 1,
            duration: 500,
          })
        }
      })
    })
  
    // Indicate that symbols are clickable by changing the cursor style to 'pointer'.
    this._mapbox.on('mousemove', event => {
      if (!this.visible || this.#loading) return

      let features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.points, this._layers.clusters] })
      this._mapbox.getCanvas().style.cursor = features.length ? 'pointer' : ''
    })
  }

  _gotoLocation(location) {
    throw new Error('_gotoLocation() must be implemented in a layer subclass')
  }

  getRenderedEventIds() {
    if (!this.visible || this.#loading) return Promise.reject()

    const features = this._mapbox.queryRenderedFeatures({ layers: [this._layers.points, this._layers.clusters] })

    return Promise.all(features.map(
      feature => this.#getRenderedEventIds(feature))
    ).then(featureArrays => {
      return [...new Set(featureArrays.flat(2))]
    })
  }

  #getRenderedEventIds(feature) {
    console.log('get event ids', this.id)
    if (feature.layer.id == this._layers.clusters) {
      return this.#getClusterFeatures(feature).then(features => {
        return features.map(f => this.AtlasApp.data.parse(f.properties).getEventIds(this.id))
      })
    } else {
      return Promise.resolve(this.AtlasApp.data.parse(featur.properties).getEventIds(this.id))
    }
  }

  #getClusterFeatures(cluster) {
    return new Promise((resolve, reject) => {
      const clusterData = this._mapbox.getSource(this._sources.locations)
      clusterData.getClusterLeaves(cluster.properties.cluster_id, 100, 0, (error, features) => {
        if (error) {
          reject(error)
        } else {
          resolve(features)
        }
      })
    })
  }

  setSelection(location) {
    if (location && location.latitude && location.longitude) {
      this._mapbox.getSource(this._sources.selection).setData({
        type: 'FeatureCollection',
        features: [{
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [location.longitude, location.latitude],
          },
        }]
      })
    } else {
      this._mapbox.getSource(this._sources.selection).setData({
        type: 'FeatureCollection',
        features: [],
      })
    }
  }

}
