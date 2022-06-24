
/* global m, Layout, MapView, ListView, EventView, VenueView */

const layout = function(view, attrs) {
  return {
    render: function() {
      attrs.view = view
      return m(Layout, attrs)
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  m.route.prefix = '/map'
  m.route(document.body, '/', {
    '/': layout(MapView, {
      map: 'fullscreen',
      panel: 'overflow',
      layer: 'offline',
    }),
    '/venue/:id': layout(VenueView, {
      model: 'venue',
      layer: 'offline',
    }),
    '/:layer': layout(ListView, {
      map: 'hidden'
    }),
    '/:layer/:id': layout(EventView, {
      panel: 'padded',
      model: 'event',
    }),
  })
})
