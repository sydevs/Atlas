
/* global m, Layout, MapView, ListView, EventView, VenueView, AreaView, PlaceView */

const layout = function(view, attrs = {}) {
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
    '/': layout(MapView, { map: 'fullscreen', panel: 'overflow' }),

    '/country/:id': layout(CountryView, { model: AtlasCountry }),
    '/region/:id': layout(RegionView, { model: AtlasRegion }),
    '/area/:id': layout(AreaView, { model: AtlasArea, map: 'freeze' }),
    '/venue/:id': layout(VenueView, { model: AtlasVenue, map: 'freeze' }),
    '/event/:id': layout(EventView, { model: AtlasEvent, map: 'freeze', panel: 'padded' }),

    '/:layer': layout(ListView, { map: 'hidden' }),
    '/:layer/country/:id': layout(CountryView, { model: AtlasCountry }),
    '/:layer/region/:id': layout(RegionView, { model: AtlasRegion }),
    '/:layer/area/:id': layout(AreaView, { model: AtlasArea, map: 'freeze' }),
    '/:layer/venue/:id': layout(VenueView, { model: AtlasVenue, map: 'freeze' }),
    '/:layer/event/:id': layout(EventView, { model: AtlasEvent, map: 'freeze', panel: 'padded' }),
  })
})
