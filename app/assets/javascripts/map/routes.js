
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
    }),
    '/:layer': layout(ListView, {
      map: 'hidden'
    }),
    '/:layer/area/:id': layout(AreaView, {
      map: 'freeze',
      model: 'area',
    }),
    '/:layer/venue/:id': layout(VenueView, {
      map: 'freeze',
      model: 'venue',
    }),
    '/:layer/event/:id': layout(EventView, {
      map: 'freeze',
      panel: 'padded',
      model: 'event',
    }),
  })
})
