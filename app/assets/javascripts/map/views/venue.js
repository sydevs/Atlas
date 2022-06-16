/* exported VenueView */

/* global m, List, NavigationButton, AtlasAPI */

function VenueView() {
  const atlas = new AtlasAPI()
  let venue = null

  const id = m.route.param('id')
  atlas.getVenue({
    id: id
  }, response => {
    venue = response
    m.redraw()
  })

  return {
    view: function() {
      if (!venue) return null //m('div', "Venue not found")

      return [
        m(NavigationButton, {
          float: 'left',
          url: '/map',
          icon: 'left',
        }),
        m('.panel__header', "Events at " + venue.label),
        m(List, { events: venue.events }),
      ]
    }
  }
}