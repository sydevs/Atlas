/* exported OnlineMapLayer */
/* global m, AbstractMapLayer */

class OnlineMapLayer extends AbstractMapLayer {

  static STYLE = 'mapbox://styles/sydevadmin/cl4nw934f001j14l8jnof3a7w'

  get style() {
    return OnlineMapLayer.STYLE
  }

  constructor(mapbox, config) {
    super(mapbox, Object.assign({
      id: 'online',
      points: {
        'text-field': '',
        'icon-image': 'cluster',
      },
      selectionZoom: 7,
      selection: {
        'text-field': '',
      },
      fetchGeojson: App.data.getGeojson('online'),
    }, config))
  }

  load() {
    // These bounds contain most of the inhabited world.
    this._mapbox.fitBounds([-180, -55, 180, 70])
    return super.load()
  }

  _gotoLocation(area) {
    if (area.eventIds.length > 1) {
      App.data.setCache('areas', area)
      m.route.set('/area/:id', { id: area.id })
    } else {
      m.route.set('/:layer/:id', { id: area.eventIds[0], layer: 'online' })
    }
  }

}
