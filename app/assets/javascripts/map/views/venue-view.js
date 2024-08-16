/* exported VenueView */

/* global m, NavigationButton, App, Util */

function VenueView() {
  let venue = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasVenue, id).then(response => {
        venue = response
        AtlasApp.data.getRecords(AtlasEvent, venue.offlineEventIds).then(events => {
          venue.events = events
          m.redraw()
        })
      })
    },
    view: function() {
      if (!venue) return m(Loader)

      return [
        m('.sya-panel__header', [
          m(NavigationButton, {
            float: 'left',
            icon: 'left',
            href: AtlasApp.config.default_view == 'list' ? '/area/:id' : '/',
            params: { id: venue.areaId }
          }),
          Util.translate('venue.header', { venue: venue.label }),
        ]),
        m('.sya-list',
          venue.events ? venue.events.map(function(event) {
            return m(EventCard, { key: event.id, class: 'sya-list__item', event: event })
          }) : m(Loader)
        )
      ]
    }
  }
}