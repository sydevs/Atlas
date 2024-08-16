/* exported ListFallback */
/* global m, Util */

function ListFallback() {
  let venue = {}

  function getClosestVenue() {
    AtlasApp.data.getClosestVenue(AtlasApp.map.getCenter()).then(response => {
      if (venue.id != response.id) {
        venue = response
        m.redraw()
      }
    })
  }

  return {
    oncreate: getClosestVenue,
    onupdate: Util.throttle(getClosestVenue, 500),
    view: function() {
      if (!venue.id) return
      const center = AtlasApp.map.getCenter()
      const distance = Util.distance_between(venue, center)
      let mode = distance < 8 ? 'nearby' : 'far'

      if (mode == 'nearby') {
        mode = 'nearby'
        link = m(m.route.Link, {
          href: '/venue/:id',
          params: { id: venue.id },
          class: 'sya-list-fallback__link',
        }, venue.label)
      } else {
        mode = 'far'
        let area = venue.area
        link = m(m.route.Link, {
          href: '/area/:id',
          params: { id: area.id },
          class: 'sya-list-fallback__link',
        }, area.label)
      }

      return m('.sya-list-fallback', [
        m('.sya-list-fallback__message', Util.translate(`list.fallback.${mode}`)),
        link,
        m('.sya-list-fallback__message', [
          Util.translate('list.fallback.online') + " ",
          m(m.route.Link, {
            href: '/online',
          }, Util.translate('navigation.mobile.online').toLowerCase()),
        ]),
      ])
    }
  }
}