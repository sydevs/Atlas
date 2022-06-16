/* exported ListFallback */
/* global m */

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
          distance < 8 ?
            "There are no classes in this area, the closest free meditation class is in" :
            "The closest free meditation class at"
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