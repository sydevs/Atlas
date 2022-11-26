/* exported VenueView */

/* global m, NavigationButton, App, Util */

function VenueView() {
  let venue = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasVenue, id).then(response => {
        venue = response
        AtlasApp.data.getEvents(venue.offlineEventIds).then(events => {
          venue.events = events
          m.redraw()
        })
      })
    },
    view: function() {
      if (!venue) return m(Loader)

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: AtlasApp.config.default_view == 'list' ? '/:layer/area/:id' : '/:layer',
          params: { layer: AtlasEvent.LAYER.offline, id: venue.parentId }
        }),
        m('.sya-panel__header', Util.translate('venue.header', { venue: venue.label })),
        m('.sya-list', venue.events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'sya-list__item', event: event })
        }))
      ]
    }
  }
}