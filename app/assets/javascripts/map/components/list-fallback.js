/* exported ListFallback */
/* global m, Util */

function ListFallback() {
  let venue = null

  return {
    oncreate: function() {
      App.atlas = new AtlasAPI()
      App.atlas.getClosestVenue({ latitude: 0, longitude: 0 }, response => {
        venue = response
        m.redraw()
      })
    },
    view: function() {
      const distance = 7 //Util.distance(venue.latitude, venue.longitude, currentCenter.latitude, currentCenter.longitude)

      return m('.list-fallback', 
        m('.list-fallback__message',
          Util.translate(distance < 8 ? 'list.fallback.nearby' : 'list.fallback.far')
        ),
        venue ?
          m(m.route.Link, {
            href: `/venue/${venue.id}`,
            class: 'list-fallback__link',
          }, venue.label) :
          null
      )
    }
  }
}