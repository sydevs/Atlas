/* exported OnlineMapLayer */
/* global m, AbstractMapLayer */

class SelectionMapLayer extends AbstractMapLayer {

  constructor(mapbox, config) {
    super(mapbox, Object.assign({
      id: 'selection',
      pointIcon: 'marker_selected',
      cluster: false,
      interactive: false,
    }, config))

    this.visible = true
  }

  setSelection(location, options) {
    if (location) {
      this._mapbox.getSource(this._layers.source).setData({
        type: 'FeatureCollection',
        features: [{
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [location.longitude, location.latitude],
          },
        }]
      })

      this.flyTo(location, options)
    } else {
      this._mapbox.getSource(this._layers.source).setData({
        type: 'FeatureCollection',
        features: [],
      })
    }
  }

  flyTo(location, options = {}) {
    let args = {
      center: [location.longitude, location.latitude],
      zoom: options.zoom || 16,
    }

    if (Util.isDevice('mobile') || options.transition == false) {
      this._mapbox.jumpTo(args)
    } else {
      this._mapbox.flyTo(args)
    }
  }

}
