/* exported VenueView */

/* global m, List, NavigationButton, App, Util */

function VenueView() {
  let venue = null

  return {
    oninit: function(vnode) {
      App.atlas.getVenue(vnode.attrs.id).then(response => {
        venue = response
        App.atlas.getEvents(venue.eventIds).then(events => {
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