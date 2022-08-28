
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
    '/area/:id': layout(AreaView, {
      map: 'freeze',
      model: 'area',
      layer: 'online',
    }),
    '/venue/:id': layout(VenueView, {
      map: 'freeze',
      model: 'venue',
      layer: 'offline',
    }),
    '/:layer': layout(ListView, {
      map: 'hidden'
    }),
    '/:layer/:id': layout(EventView, {
      map: 'freeze',
      panel: 'padded',
      model: 'event',
    }),
  })
})
