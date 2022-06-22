/* exported ListFallback */
/* global m, Util */

function ListFallback() {
  let venue = {}

  return {
    onupdate: function() {
      App.atlas.getClosestVenue(App.map.getCenter()).then(response => {
        if (venue.id != response.id) {
          venue = response
          m.redraw()
        }
      })
    },
    view: function() {
      if (!venue.id) return
      const center = App.map.getCenter()
      const distance = Util.distance(venue.latitude, venue.longitude, center.latitude, center.longitude)

      return m('.list-fallback', 
        m('.list-fallback__message',
          Util.translate(distance < 8 ? 'list.fallback.venue' : 'list.fallback.area')
        ),
        venue.id ?
          m(m.route.Link, {
            href: `/venue/${venue.id}`,
            class: 'list-fallback__link',
          }, venue.label) :
          null
      )
    }
  }
}