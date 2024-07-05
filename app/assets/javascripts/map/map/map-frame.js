/* exported MapFrame */
/* global mapboxgl, MapboxLanguage, OnlineMapLayer, OfflineMapLayer, SelectionMapLayer */

class MapFrame extends EventTarget {

  static EMPTY_STYLE = { version: 8, sources: {}, layers: [] }

  // Private variables
  #mapbox
  #loading = true
  #layers = {}
  #controls = {}
  #currentLayerId
  #userLocation = null
  #userLocationMarker
  #hasSelection = false

  // Getters
  get loading() {
    return this.#loading || this.#currentLayer.loading
  }

  get sortLocation() {
    return this.#userLocation || this.getCenter()
  }

  get userLocation() {
    return this.#userLocation
  }

  get #currentLayer() {
    return this.#layers[this.#currentLayerId]
  }

  constructor(containerId, config) {
    super()

    config = Object.assign({
      onload: () => {},
    }, config)

    mapboxgl.accessToken = AtlasApp.config.token

    console.log('CONFIG', AtlasApp.config)
    this.#mapbox = new mapboxgl.Map({
      container: containerId,
      style: MapFrame.EMPTY_STYLE,
      minZoom: 1,
      dragRotate: false,
      hash: true,
      fitBounds: { easing: { animate: false, padding: 10 } },
      bounds: AtlasApp.config.bounds,
      center: AtlasApp.config.center,
      worldview: AtlasApp.config.country,
    })

    this.#updatePadding()

    let initalizing = true

    this.#mapbox.on('load', () => {
      initalizing = false
      this.#layers = {}
      this.#layers[AtlasEvent.LAYER.online] = new OnlineMapLayer(this.#mapbox)
      this.#layers[AtlasEvent.LAYER.offline] = new OfflineMapLayer(this.#mapbox)

      this.showLayer(config.layer)
      this.loadControlLayers()
      this._setupHooks()
    })

    this.#mapbox.on('style.load', () => {
      if (initalizing) return

      this.#loading = true
      this.#currentLayer.visible = true

      this.#currentLayer.load().then(() => {
        this.#loading = false
        this.dispatchEvent(new Event('load'))
        this.dispatchEvent(new Event('update'))
      })
    })
  }

  setPositionToAnchor(anchor) {
    let position = anchor.split('/')
    if (position.length != 3) return

    this.#mapbox.jumpTo({ zoom: position[0], center: [position[2], position[1]] })
  }

  waitForLoad() {
    if (this.#loading) {
      return new Promise((resolve, reject) => {
        this.addEventListener('load', () => resolve())
      })
    } else {
      return Promise.resolve()
    }
  }

  loadControlLayers() {
    if (this.#controls != null) this.removeControlLayers()

    this.#controls = {
      language: new MapboxLanguage({ defaultLanguage: AtlasApp.config.locale }),
      navigation: new mapboxgl.NavigationControl({ showCompass: false }),
      geolocater: new mapboxgl.GeolocateControl(),
    }

    this.#controls.geolocater.on('geolocate', event => {
      this.setUserLocation(event.coords, true)
    })

    Object.values(this.#controls).forEach(control => this.#mapbox.addControl(control))
  }

  removeControlLayers() {
    Object.values(this.#controls).forEach(control => this.#mapbox.removeControl(control))
    this.#controls = null
  }

  setFreeze(freeze) {
    const handlers = ['scrollZoom', 'boxZoom', 'dragRotate', 'dragPan', 'keyboard', 'doubleClickZoom', 'touchZoomRotate']

    if (freeze) {
      handlers.forEach(handler => this.#mapbox[handler].disable())
    } else {
      handlers.forEach(handler => this.#mapbox[handler].enable())
    }
  }

  _setupHooks() {
    window.addEventListener('resize', _event => this.#updatePadding())
    this.#mapbox.on('render', _event => this.dispatchEvent(new Event('update')))
    this.#mapbox.on('movestart', _event => this.dispatchEvent(new Event('movestart')))
    this.#mapbox.on('move', _event => this.dispatchEvent(new Event('move')))
    this.#mapbox.on('moveend', _event => this.dispatchEvent(new Event('moveend')))
  }

  getRenderedEventIds() {
    if (this.#loading) return Promise.reject()

    return this.#currentLayer.getRenderedEventIds()
  }

  showLayer(layerId) {
    layerId ||= AtlasEvent.LAYER.offline
    if (layerId == this.#currentLayerId) return

    Object.values(this.#layers).forEach(layer => { layer.visible = false })
    this.#currentLayerId = layerId
    this.#mapbox.setStyle(this.#layers[layerId].style)
  }

  async setSelection(location, options = {}) {
    this.waitForLoad().then(() => {
      this.#currentLayer.setSelection(location)
      if (!location) {
        if (this.#hasSelection) {
          //this.#mapbox.easeTo({ zoom: this.#mapbox.getZoom() * 0.75 })
          this.#hasSelection = false
        }

        window.document.title = Util.translate('meditation_atlas')
        this.#hasSelection = false
        return
      }

      this.#hasSelection = true
      window.document.title = location.label || Util.translate('meditation_atlas')

      if (location instanceof AtlasRegion) {
        location.bounds = (this.#currentLayerId == AtlasEvent.LAYER.online ? location.onlineEventBounds : location.offlineEventBounds )
      }
      
      if (location.bounds || (location.radius && location.radius != 'null')) {
        this.fitTo(location, Object.assign({
          transition: true
        }, options))
      } else {
        this.goTo(location, Object.assign({
          zoom: this.#currentLayerId == AtlasEvent.LAYER.online ? 7 : 16,
          transition: true,
        }, options))
      }
    })
  }

  getCenter() {
    const center = this.#mapbox.getCenter()
    return { latitude: center.lat, longitude: center.lng }
  }

  resize() {
    this.#mapbox.resize()
  }

  destroy() {
    this.#mapbox.remove()
  }

  goTo(location, options = {}) {
    if (!location) return
    
    const args = {
      center: [location.longitude, location.latitude],
      zoom: options.zoom || 16,
    }

    this.#updatePadding()
    if (Util.isDevice('mobile') || options.transition == false) {
      this.#mapbox.jumpTo(args)
    } else {
      this.#mapbox.flyTo(args)
    }
  }

  fitTo(location, options = {}) {
    if (!location) return
    let bounds
    
    if (location.radius) {
      bounds = new mapboxgl.LngLat(location.longitude, location.latitude).toBounds(location.radius * 1000)
    } else if (location.bounds) {
      bounds = location.bounds
      bounds = [[bounds[2], bounds[0]], [bounds[3], bounds[1]]]
    } else {
      bounds = [[location.west, location.south], [location.east, location.north]]
    }

    this.#updatePadding()
    this.#mapbox.fitBounds(bounds, {
      animate: (options.transition != false) && !Util.isDevice('mobile'),
    })
  }

  setUserLocation(location, disableMarker = false) {
    this.location = location

    if (!this.#userLocationMarker) {
      this.#userLocationMarker = new mapboxgl.Marker()
    }

    if (disableMarker || location == null) {
      this.#userLocationMarker.remove()
    } else {
      this.#userLocationMarker.setLngLat([location.longitude, location.latitude]).addTo(this.#mapbox)
    }
  }

  getCenter() {
    const center = this.#mapbox.getCenter()
    return { latitude: center.lat, longitude: center.lng }
  }

  #updatePadding() {
    let padding = {}
    const basePadding = 5

    if (Util.isDevice('mobile')) {
      padding = { top: 80 }
    } else if (Util.isDevice('desktop')) {
      padding = { left: 532 + basePadding }
    }

    ['top', 'left', 'bottom', 'right'].forEach(side => {
      if (typeof padding[side] === 'undefined') {
        padding[side] = basePadding
      }
    })

    this.#mapbox.setPadding(padding)
  }

}