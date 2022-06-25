/* exported VenueView */

/* global m, List, NavigationButton, App, Util */

function VenueView() {
  let venue = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      App.data.getVenue(id).then(response => {
        venue = response
        App.data.getEvents(venue.eventIds).then(events => {
          venue.events = events
          m.redraw()
        })
      })
    },
    view: function() {
      if (!venue) return null //m('div', "Venue not found")

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/',
        }),
        m('.panel__header', Util.translate('venue.header', { venue: venue.label })),
        m(List, { events: venue.events }),
      ]
    }
  }
}