
/* global m, Layout, MapView, ListView, EventView, VenueView, AreaView, PlaceView */

class SahajAtlas {
  data = null
  map = null
  #container

  constructor() {
    this.data = new DataCache()
    this.#container = document.getElementById('sahaj-atlas')
    this.#container.style = `height: calc(100vh - ${this.#container.offsetTop}px)`
    document.addEventListener('resize', () => m.redraw())
  }

  setup() {
    const layout = function(view, attrs = {}) {
      return {
        render: function() {
          attrs.view = view
          return m(Layout, attrs)
        }
      }
    }
    
    m.route.prefix = window.sya.config.path || window.location.pathname.split('map')[0] + 'map'
    m.route(this.#container, window.sya.config.prefix, {
      '/': layout(MapView, { map: 'fullscreen', panel: 'overflow' }),
  
      '/country/:id': layout(CountryView, { model: AtlasCountry, map: 'halfscreen' }),
      '/region/:id': layout(RegionView, { model: AtlasRegion, map: 'halfscreen' }),
      '/area/:id': layout(AreaView, { model: AtlasArea, map: 'freeze' }),
      '/venue/:id': layout(VenueView, { model: AtlasVenue, map: 'freeze' }),
      '/event/:id': layout(EventView, { model: AtlasEvent, map: 'freeze', panel: 'padded' }),
  
      '/:layer': layout(ListView, { map: 'hidden' }),
      '/:layer/country/:id': layout(CountryView, { model: AtlasCountry, map: 'halfscreen' }),
      '/:layer/region/:id': layout(RegionView, { model: AtlasRegion, map: 'halfscreen' }),
      '/:layer/area/:id': layout(AreaView, { model: AtlasArea, map: 'freeze' }),
      '/:layer/venue/:id': layout(VenueView, { model: AtlasVenue, map: 'freeze' }),
      '/:layer/event/:id': layout(EventView, { model: AtlasEvent, map: 'freeze', panel: 'padded' }),
    })
  }
}

function loadAtlas() {
  window.AtlasApp = new SahajAtlas()
  AtlasApp.setup()
}

if (/complete|interactive|loaded/.test(document.readyState)) {
  setTimeout(loadAtlas, 1)
} else {
  document.addEventListener('DOMContentLoaded', loadAtlas)
}
