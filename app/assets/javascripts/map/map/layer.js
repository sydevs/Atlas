/* exported AbstractMapLayer */
/* global m, App */

class AbstractMapLayer {

  // Private methods
  #config
  #visible = false
  #loading = true

  // Protected methods
  _mapbox
  _layers = {}

  // Getters
  get #visibility() {
    return this.#visible ? 'visibility' : 'none'
  }

  constructor(mapbox, config) {
    config = Object.assign({
      autoload: true,
      cluster: true,
      pointIcon: 'marker_default',
      clusterIcon: 'cluster-1',
      visible: false,
      interactive: true,
    }, config)

    this.#config = config
    this._mapbox = mapbox
    this.#visible = config.visible
    this._layers = {
      source: `${config.id}-source`,
      points: `${config.id}-points`,
    }

    if (config.cluster) {
      this._layers.clusters = `${config.id}-clusters`
    }

    if (config.autoload) {
      App.atlas.getGeojson(config.id).then(geojson => this.load(config, geojson))
    } else {
      this.load(config)
    }
  }

  load(config, geojson) {
    this.loadLayers(config, geojson)
    if (config.interactive) {
      this.createEvents(config)
    }

    if (config.onload) config.onload(config.id)
    this.#loading = false
  }

  loadLayers(config, geojson = null) {
    if (config.cluster) {
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

    if (config.cluster) {
      this._mapbox.addLayer({
        id: this._layers.clusters,
        type: 'symbol',
        source: this._layers.source,
        filter: ['has', 'point_count'],
        layout: {
          //'visibility': this.#visibility,
          'icon-allow-overlap': true,
          'icon-ignore-placement': true,
          'icon-image': config.clusterIcon,
          'text-field': '{point_count_abbreviated}',
          'text-font': ['DIN Offc Pro Bold', 'Arial Unicode MS Bold'],
          'text-size': 12,
        },
        paint: {
          'text-color': '#FFFFFF',
        },
      })
    }

    this._mapbox.addLayer({
      id: this._layers.points,
      type: 'symbol',
      source: this._layers.source,
      filter: ['!', ['has', 'point_count']],
      layout: {
        //'visibility': this.#visibility,
        'icon-ignore-placement': true,
        'icon-image': config.pointIcon,
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })
  }

  createEvents(config) {
    this._mapbox.on('click', event => {
      let features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.points] })
      if (features.length < 1) return

      let location = this.#parseLocation(features[0])
      this.showLocation(location)
    })

    if (config.cluster) {
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
      if (!this.#visible) return

      let features = this._mapbox.queryRenderedFeatures(event.point, { layers: [this._layers.points, this._layers.clusters] })
      this._mapbox.getCanvas().style.cursor = features.length ? 'pointer' : ''
    })
  }

  showLocation(location) {
    throw new Error('showLocation() must be implemented in a layer subclass')
  }

  toggle(visible) {
    this.#visible = visible
    if (this.#loading) return

    this._mapbox.setLayoutProperty(this._layers.clusters, 'visibility', this.#visibility)
    this._mapbox.setLayoutProperty(this._layers.points, 'visibility', this.#visibility)
    this._mapbox.setStyle(this.#config.style)
  }

  #parseLocation(feature) {
    const location = feature.properties
    if (typeof location.eventIds === 'string') {
      location.eventIds = JSON.parse(location.eventIds)
    }

    return location
  }

}
