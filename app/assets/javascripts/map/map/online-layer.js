/* exported OnlineMapLayer */
/* global App */

class OnlineMapLayer {

  constructor(mapbox) {
    this.mapbox = mapbox
    this.visibility = 'none'
    this.loading = true
    this.layers = {
      source: 'online-source',
      points: 'online-points',
    }

    this.mapbox.on('load', _event => {
      App.atlas.getGeojson('online', geojson => {
        this.loadLayers(geojson)
        this.createEvents()
        this.loading = false
      })
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
      id: this.layers.points,
      type: 'symbol',
      source: this.layers.source,
      layout: {
        'visibility': this.visibility,
        'icon-allow-overlap': false,
        'icon-image': 'cluster-1',
        'text-field': '{point_count_abbreviated}',
        'text-font': ['DIN Offc Pro Bold', 'Arial Unicode MS Bold'],
        'text-size': 12,
      },
      paint: {
        'text-color': '#FFFFFF',
      },
    })

    /*
    this.mapbox.addSource(this.selectedVenueSource, { type: 'geojson', data: null })
    this.mapbox.addLayer({
      id: this.selectedVenueLayer,
      type: 'symbol',
      source: this.selectedVenueSource,
      filter: ['!', ['has', 'point_count']],
      layout: {
        'icon-ignore-placement': true,
        'icon-image': 'marker_selected',
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
    })
    */
  }

  createEvents() {
    // todo
  }

  toggle(visible) {
    this.visibility = visible ? 'visible' : 'none'
    if (this.loading) return

    this.mapbox.setLayoutProperty(this.layers.points, 'visibility', this.visibility)
  }

}