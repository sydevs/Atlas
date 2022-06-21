
/* global m, Layout, MapView, ListView, EventView, VenueView */

const layout = function(view, attrs) {
  return {
    render: function() {
      let id = m.route.param('id')
      let viewAttrs = {}

      if (id) {
        attrs.id = id
        viewAttrs = { id: id, key: id }
      }

      return m(Layout, attrs, m(view, viewAttrs))
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  m.route(document.body, '/', {
    '/': layout(MapView, {
      map: 'fullscreen',
      panel: 'overflow',
    }),
    '/list/:layer': layout(ListView, {
      map: 'hidden'
    }),
    '/event/:id': layout(EventView, {
      panel: 'padded',
      model: 'event',
    }),
    '/venue/:id': layout(VenueView, {
      model: 'venue',
      layer: 'offline',
    }),
  })
})
