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
        'text-field': '1',
        'icon-image': 'cluster',
      },
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
    m.route.set('/:layer/:id', { id: area.eventIds[0], layer: 'online' })

    /*if (venue.eventIds.length > 1) {
      App.data.setCache('venues', venue)
      m.route.set('/venue/:id', { id: venue.id })
    } else {
      m.route.set('/:layer/:id', { id: venue.eventIds[0], layer: 'online' })
    }*/
  }

}
