/* exported OnlineMapLayer */
/* global m, AbstractMapLayer */

class OnlineMapLayer extends AbstractMapLayer {

  static STYLE = 'mapbox://styles/sydevadmin/cl4nw934f001j14l8jnof3a7w'

  get style() {
    return OnlineMapLayer.STYLE
  }

  constructor(mapbox, config) {
    super(mapbox, Object.assign({
      id: AtlasEvent.LAYER.online,
      points: {
        'text-field': '',
        'icon-image': 'cluster',
      },
      selectionZoom: 7,
      selection: {
        'text-field': '',
      },
      fetchGeojson: AtlasApp.data.getGeojson(AtlasEvent.LAYER.online),
    }, config))
  }

  load() {
    // These bounds contain most of the inhabited world.
    //this._mapbox.fitBounds([-180, -55, 180, 70])
    return super.load()
  }

  _gotoLocation(area) {
    if (area.onlineEventIds.length > 1) {
      AtlasApp.data.setCache('area', area.id, area)
      m.route.set('/area/:id', { id: area.id })
    } else {
      let backPath = m.route.get().split('#')[0] + window.location.hash
      m.route('/event/:id', { id: area.eventIds[0], back: backPath })
    }
  }

}
