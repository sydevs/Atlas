/* exported MapFrame */
/* global mapboxgl, MapboxLanguage, OnlineMapLayer, OfflineMapLayer, SelectionMapLayer */

class MapFrame {

  static EMPTY_STYLE = { version: 8,sources: {},layers: [] }

  // Private variables
  #mapbox
  #loading = true
  #layers = {}
  #selectionLayer
  #currentLayerId

  // Getters
  get loading() {
    return this.#loading
  }

  get #currentLayer() {
    return this.#layers[this.#currentLayerId]
  }

  constructor(containerId, config) {
    config = Object.assign({
      onload: () => {},
    }, config)

    mapboxgl.accessToken = 'pk.eyJ1Ijoic3lkZXZhZG1pbiIsImEiOiJjazczcXV4ZzQwZXJtM3JxZTF6a2g0dW9hIn0.avMfkC306-2PqpNRnz6otg'

    this.#mapbox = new mapboxgl.Map({
      container: containerId,
      style: MapFrame.EMPTY_STYLE,
      minZoom: 1,
      dragRotate: false,
      hash: true,
    })

    let initalizing = true

    this.#mapbox.on('load', () => {
      console.log('mapbox load')
      initalizing = false
      this.#selectionLayer = new SelectionMapLayer(this.#mapbox)
      this.#layers = {
        online: new OnlineMapLayer(this.#mapbox),
        offline: new OfflineMapLayer(this.#mapbox),
      }

      this.showLayer(config.layer)
      this.loadControlLayers()
    })

    this.#mapbox.on('style.load', () => {
      if (initalizing) return

      console.log('mapbox style load')
      this.#loading = true
      this.#currentLayer.visible = true

      this.#currentLayer.load().then(() => {
        this.#selectionLayer.load()
        this.#loading = false
        config.onload()
      })
    })
  }

  loadControlLayers() {
    this.#mapbox.addControl(new MapboxLanguage({ defaultLanguage: window.locale }))
    this.#mapbox.addControl(new mapboxgl.NavigationControl({ showCompass: false }))

    const geolocater = new mapboxgl.GeolocateControl()
    this.#mapbox.addControl(geolocater)

    geolocater.on('geolocate', event => {
      this.setUserLocation(event.coords, true)
    })
  }

  createEvents() {
    //window.addEventListener('resize', _event => this.updatePadding())
  }

  showLayer(layerId) {
    layerId ||= 'offline'
    if (layerId == this.#currentLayerId) return

    Object.values(this.#layers).forEach(layer => { layer.visible = false })
    this.#currentLayerId = layerId
    this.#mapbox.setStyle(this.#layers[layerId].style)
  }

  setSelection(location, options) {
    this.#selectionLayer.setSelection(location, options)
  }

  resize() {
    this.#mapbox.resize()
  }

  destroy() {
    this.#mapbox.remove()
  }

}