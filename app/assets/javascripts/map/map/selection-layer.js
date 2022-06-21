/* exported OnlineMapLayer */
/* global m, AbstractMapLayer */

class SelectionMapLayer extends AbstractMapLayer {

  constructor(mapbox, config) {
    super(mapbox, Object.assign({
      id: 'selection',
      pointIcon: 'marker_selected',
      cluster: false,
      visible: true,
      interactive: false,
      autoload: false,
    }, config))
  }

  surfaceSelectionLayer() {
    this._mapbox.moveLayer(this._layers.points)
  }

  setSelection(location) {
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

      console.log('flyTo', location)
      this.flyTo(location, 16)
    } else {
      this._mapbox.getSource(this._layers.source).setData({
        type: 'FeatureCollection',
        //features: [],
        features: [{
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [0, 0],
          },
        }]
      })
    }
  }

  flyTo(location, zoom) {
    let options = {
      center: [location.longitude, location.latitude],
      zoom: zoom,
    }

    if (Util.isDevice('mobile')) {
      this._mapbox.jumpTo(options)
    } else {
      this._mapbox.flyTo(options)
    }
  }

}
