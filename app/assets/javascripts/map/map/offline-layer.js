/* exported OfflineMapLayer */
/* global m, AbstractMapLayer */

class OfflineMapLayer extends AbstractMapLayer {

  static STYLE = 'mapbox://styles/sydevadmin/ck7g6nag70rn11io09f45odkq'

  get style() {
    return OfflineMapLayer.STYLE
  }

  constructor(mapbox, config) {
    super(mapbox, Object.assign({
      id: 'offline',
      cluster: true,
      fetchGeojson: App.atlas.getGeojson('offline'),
    }, config))
  }

  _gotoLocation(venue) {
    if (venue.eventIds.length > 0) {
      App.atlas.setCache('venues', venue)
      m.route.set('/venue/:id', { id: venue.id })
    } else {
      m.route.set('/event/:id', { id: venue.eventIds[0] })
    }
  }

}
