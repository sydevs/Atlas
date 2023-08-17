/* exported OfflineMapLayer */
/* global m, AbstractMapLayer */

class OfflineMapLayer extends AbstractMapLayer {

  static STYLE = 'mapbox://styles/sydevadmin/ck7g6nag70rn11io09f45odkq'

  get style() {
    return OfflineMapLayer.STYLE
  }

  constructor(mapbox, config) {
    super(mapbox, Object.assign({
      id: AtlasEvent.LAYER.offline,
      points: {
        'icon-anchor': 'bottom',
        'icon-size': 0.85,
      },
      fetchGeojson: AtlasApp.data.getGeojson(AtlasEvent.LAYER.offline),
    }, config))
  }

  _gotoLocation(venue) {
    if (venue.offlineEventIds.length > 1) {
      AtlasApp.data.setCache('venue', venue.id, venue)
      m.route.set('/venue/:id', { id: venue.id })
    } else {
      let backPath = m.route.get().split('#')[0] + window.location.hash
      m.route.set('/event/:id', {
        id: venue.offlineEventIds[0],
        back: backPath,
      })
    }
  }

}
