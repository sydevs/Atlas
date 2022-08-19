/* exported MapFrame */
/* global mapboxgl, MapboxLanguage, OnlineMapLayer, OfflineMapLayer, SelectionMapLayer */

class MapFrame extends EventTarget {

  static EMPTY_STYLE = { version: 8,sources: {},layers: [] }

  // Private variables
  #mapbox
  #loading = true
  #layers = {}
  #controls = {}
  #currentLayerId
  #userLocation = null
  #userLocationMarker

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

    mapboxgl.accessToken = window.config.token

    this.#mapbox = new mapboxgl.Map({
      container: containerId,
      style: MapFrame.EMPTY_STYLE,
      minZoom: 1,
      dragRotate: false,
      hash: true,
      bounds: window.config.bounds,
      center: window.config.center,
    })

    let initalizing = true

    this.#mapbox.on('load', () => {
      initalizing = false
      this.#layers = {
        online: new OnlineMapLayer(this.#mapbox),
        offline: new OfflineMapLayer(this.#mapbox),
      }

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
      language: new MapboxLanguage({ defaultLanguage: window.locale }),
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
    //window.addEventListener('resize', _event => this.updatePadding())
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
    layerId ||= 'offline'
    if (layerId == this.#currentLayerId) return

    Object.values(this.#layers).forEach(layer => { layer.visible = false })
    this.#currentLayerId = layerId
    this.#mapbox.setStyle(this.#layers[layerId].style)
  }

  async setSelection(location, options = {}) {
    this.waitForLoad().then(() => {
      this.#currentLayer.setSelection(location)
      if (!location) return

      if (location.radius) {
        this.fitTo(location, Object.assign({
          transition: true
        }, options))
      } else {
        this.goTo(location, Object.assign({
          zoom: this.#currentLayerId == 'offline' ? 4 : 16,
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

    if (Util.isDevice('mobile') || options.transition == false) {
      this.#mapbox.jumpTo(args)
    } else {
      this.#mapbox.flyTo(args)
    }
  }

  fitTo(bounds, options = {}) {
    if (!bounds) return
    
    if (bounds.radius) {
      bounds = new mapboxgl.LngLat(bounds.longitude, bounds.latitude).toBounds(bounds.radius * 1000)
    } else {
      bounds = [[bounds.west, bounds.south], [bounds.east, bounds.north]]
    }

    //this.updatePadding()
    this.#mapbox.fitBounds(bounds, {
      animate: options.transition && !Util.isDevice('mobile'),
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

}