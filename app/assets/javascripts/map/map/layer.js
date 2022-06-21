/* exported AbstractMapLayer */
/* global m, App */

class AbstractMapLayer {

  // Public variables
  visible = false

  // Protected variables
  _mapbox
  _layers = {}

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
      cluster: true,
      interactive: true,
      pointIcon: 'marker_default',
      clusterIcon: 'cluster-1',
      fetchGeojson: Promise.resolve(null)
    }, config)

    this.#config = config
    this._mapbox = mapbox
    this._layers = {
      source: `${config.id}-source`,
      points: `${config.id}-points`,
    }

    if (config.cluster) {
      this._layers.clusters = `${config.id}-clusters`
    }

    if (config.interactive) {
      this.createEvents()
    }
  }

  load() {
    this.#loading = true
    return this.#config.fetchGeojson.then(geojson => {
      this.#loadSublayers(geojson)
      this.#loading = false
    })
  }

  #loadSublayers(geojson) {
    console.log('load sublayers', this.id)

    // Create source
    if (this.#config.cluster) {
      this._mapbox.addSource(this._layers.source, {
        type: 'geojson',
        data: geojson,
        cluster: true,
        clusterMaxZoom: 12, // Max zoom to cluster points on
        clusterRadius: 50, // Radius of each cluster when clustering points
      })
    } else {
      this._mapbox.addSource(this._layers.source, {
        type: 'geojson',
        data: geojson,
      })
    }

    // Create cluster layer
    if (this.#config.cluster) {
      this._mapbox.addLayer({
        id: this._layers.clusters,
        type: 'symbol',
        source: this._layers.source,
        filter: ['has', 'point_count'],
        layout: {
          'icon-allow-overlap': true,
          'icon-ignore-placement': true,
          'icon-image': this.#config.clusterIcon,
          'text-field': '{point_count_abbreviated}',
          'text-font': ['DIN Offc Pro Bold', 'Arial Unicode MS Bold'],
          'text-size': 12,
        },
        paint: {
          'text-color': '#FFFFFF',
        },
      })
    }

    // Create points layer
    this._mapbox.addLayer({
      id: this._layers.points,
      type: 'symbol',
      source: this._layers.source,
      filter: ['!', ['has', 'point_count']],
      layout: {
        'icon-ignore-placement': true,
        'icon-image': this.#config.pointIcon,
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })
  }

  createEvents() {
    this._mapbox.on('click', this._layers.points, event => {
      let features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.points] })
      if (features.length < 1) return

      let location = this.#parseLocation(features[0])
      this.showLocation(location)
    })

    if (this.#config.cluster) {
      this._mapbox.on('click', this._layers.clusters, event => {
        var features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.clusters] })
        var clusterId = features[0].properties.cluster_id
        this._mapbox.getSource(this._layers.cluster).getClusterExpansionZoom(clusterId, (error, zoom) => {
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
    }
  
    // Indicate that symbols are clickable by changing the cursor style to 'pointer'.
    this._mapbox.on('mousemove', event => {
      if (!this.visible || this.loading) return

      let features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.points, this._layers.clusters] })
      this._mapbox.getCanvas().style.cursor = features.length ? 'pointer' : ''
    })
  }

  showLocation(location) {
    throw new Error('showLocation() must be implemented in a layer subclass')
  }

  #parseLocation(feature) {
    const location = feature.properties
    if (typeof location.eventIds === 'string') {
      location.eventIds = JSON.parse(location.eventIds)
    }

    return location
  }

}
