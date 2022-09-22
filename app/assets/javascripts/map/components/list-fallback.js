/* exported ListFallback */
/* global m, Util */

function ListFallback() {
  let venue = {}
  let attemptsAllowed = 10

  return {
    onupdate: function() {
      attemptsAllowed -= 1
      if (attemptsAllowed < 0) return

      AtlasApp.data.getClosestVenue(AtlasApp.map.getCenter()).then(response => {
        if (venue.id != response.id) {
          venue = response
          m.redraw()
        }
      })
    },
    view: function() {
      if (!venue.id) return
      const center = AtlasApp.map.getCenter()
      const distance = Util.distance(venue, center)
      let mode = 'online'

      if (distance < 8) {
        mode = 'nearby'
      } else {
        mode = 'far'
      }

      return m('.sya-list-fallback', 
        m('.sya-list-fallback__message',
          Util.translate(`list.fallback.${mode}`)
        ),
        mode == 'online' ?
          m(m.route.Link, {
            href: '/:layer',
            params: { layer: AtlasEvent.LAYER.online },
            class: 'sya-list-fallback__link',
          }, Util.translate('list.fallback.online_event')) :
          m(m.route.Link, {
            href: '/:layer/venue/:id',
            params: { layer: AtlasEvent.LAYER.offline, id: venue.id },
            class: 'sya-list-fallback__link',
          }, venue.label)
      )
    }
  }
}