
/* global m, Layout, MapView, ListView, EventView, VenueView, AreaView, PlaceView */

class SahajAtlas {
  data = null
  map = null
  #config = {}
  #container

  get config() {
    return this.#config
  }

  constructor(container) {
    this.#container = container
    this.#container.style = `height: calc(100vh - ${this.#container.offsetTop}px)`
    this.#config = window.sya.config
    this.data = new DataCache(this.#config.endpoint, this.#config.locale)
    document.addEventListener('resize', () => m.redraw())

    const params = new Proxy(new URLSearchParams(window.location.search), {
      get: (searchParams, prop) => searchParams.get(prop),
    })

    if (params.q && params.latitude && params.longitude) {
      this.#config.query = {
        label: params.q,
        latitude: params.latitude,
        longitude: params.longitude,
        type: params.type,
      }
    }
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

    let basePath = this.#config.path || window.location.pathname.split('map')[0] + 'map'

    if (this.#config.routing_type == 'path' || this.#config.routing_type === undefined) {
      m.route.prefix = basePath
    } else {
      m.route.prefix = '?'
      window.history.replaceState({}, document.title, window.location.pathname)
    }

    m.route(this.#container, '/', {
      '/': layout(MapView, { map: 'fullscreen', panel: 'overflow' }),
      '/events': layout(ListView, { map: 'hidden' }),
      '/online': layout(ListView, { map: 'hidden', onlineOnly: true }),
  
      '/country/:id': layout(CountryView, { model: AtlasCountry, map: 'halfscreen' }),
      '/region/:id': layout(RegionView, { model: AtlasRegion, map: 'halfscreen' }),
      '/area/:id': layout(AreaView, { model: AtlasArea, map: 'freeze' }),
      '/venue/:id': layout(VenueView, { model: AtlasVenue, map: 'freeze' }),
      '/event/:id': layout(EventView, { model: AtlasEvent, map: 'freeze', panel: 'padded' }),
    })

    let currentPath = m.route.get().split('#')[0]

    if (this.config.default_view == 'list' && (currentPath == '' || currentPath == '/')) {
      m.route.set('/:model/:id', {
        model: this.#config.location_type,
        id: this.#config.location_id,
      })
    }
  }
}

function loadAtlas() {
  let container = document.getElementById('sahajatlas')
  if (container) {
    window.AtlasApp = new SahajAtlas(container)
    AtlasApp.setup()
  } else {
    console.warn("Could not find #sahajatlas element.")
  }
}

if (/complete|interactive|loaded/.test(document.readyState)) {
  setTimeout(loadAtlas, 1)
} else {
  document.addEventListener('DOMContentLoaded', loadAtlas)
}
