/* exported OfflineMapLayer */
/* global m, App */

class OfflineMapLayer {

  constructor(mapbox) {
    this.mapbox = mapbox
    this.visibility = 'none'
    this.loading = true
    this.layers = {
      source: 'offline-source',
      clusters: 'offline-clusters',
      points: 'offline-points',
      selected: 'offline-selected',
      selectedSource: 'offline-selectedSource',
    }

    App.atlas.getGeojson('offline').then(geojson => {
      this.loadLayers(geojson)
      this.createEvents()
      this.loading = false
    })
  }

  loadLayers(data) {
    this.mapbox.addSource(this.layers.source, {
      type: 'geojson',
      data: data,
      cluster: true,
      clusterMaxZoom: 12, // Max zoom to cluster points on
      clusterRadius: 50, // Radius of each cluster when clustering points
    })

    this.mapbox.addLayer({
      id: this.layers.clusters,
      type: 'symbol',
      source: this.layers.source,
      filter: ['has', 'point_count'],
      layout: {
        //'visibility': 'none',
        'icon-allow-overlap': true,
        'icon-ignore-placement': true,
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
      id: this.layers.points,
      type: 'symbol',
      source: this.layers.source,
      filter: ['!', ['has', 'point_count']],
      layout: {
        //'visibility': 'none',
        'icon-ignore-placement': true,
        'icon-image': 'marker_default',
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })

    this.mapbox.addSource(this.layers.selectedSource, { type: 'geojson', data: null })
    this.mapbox.addLayer({
      id: this.layers.selected,
      type: 'symbol',
      source: this.layers.selectedSource,
      filter: ['!', ['has', 'point_count']],
      layout: {
        //'visibility': 'none',
        'icon-ignore-placement': true,
        'icon-image': 'marker_selected',
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })
  }

  createEvents() {
    this.mapbox.on('click', event => {
      let features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.layers.points] })
      if (features.length < 1) return

      let venue = parseVenue(features[0])
      console.log('show venue?', venue.eventIds.length, venue)
      if (venue.eventIds.length > 1) {
        // TODO: avoid this direct access to the cache
        App.atlas.setCache('venues', venue)
        m.route.set('/venue/:id', { id: venue.id })
      } else {
        m.route.set('/event/:id', { id: venue.eventIds[0] })
      }
    })

    this.mapbox.on('click', this.clusteredCirclesLayer, event => {
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.layers.clusters] })
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
      var features = this.mapbox.queryRenderedFeatures(event.point, { layers: [this.layers.points, this.layers.clusters] })
      this.mapbox.getCanvas().style.cursor = features.length ? 'pointer' : ''
    })
  }

  toggle(visible) {
    this.visibility = visible ? 'visible' : 'none'
    if (this.loading) return

    this.mapbox.setLayoutProperty(this.layers.clusters, 'visibility', this.visibility)
    this.mapbox.setLayoutProperty(this.layers.points, 'visibility', this.visibility)
  }

}

const parseVenue = function(feature) {
  const venue = feature.properties
  if (typeof venue.eventIds === 'string') {
    venue.eventIds = JSON.parse(venue.eventIds)
  }

  return venue
}