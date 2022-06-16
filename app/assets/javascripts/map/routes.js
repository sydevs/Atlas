
/* global m, Layout, MapView, ListView, EventView, VenueView */

const layout = function(view, attrs) {
  return {
    render: function() {
      return m(Layout, attrs, m(view))
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  m.route(document.body, '/', {
    '/': layout(MapView, { map: 'fullscreen', panel: 'overflow' }),
    '/list/:type': layout(ListView, { map: 'hidden' }),
    '/event/:id': layout(EventView, { panel: 'padded' }),
    '/venue/:id': layout(VenueView),
  })
})
