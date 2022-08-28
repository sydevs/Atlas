/* exported VenueView */

/* global m, NavigationButton, App, Util */

function VenueView() {
  let venue = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      App.data.getRecord(AtlasVenue, id).then(response => {
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
        m('.list', venue.events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'list__item', event: event })
        }))
      ]
    }
  }
}