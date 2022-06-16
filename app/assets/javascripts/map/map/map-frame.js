/* exported MapFrame */
/* global mapboxgl, MapboxLanguage, OnlineMapLayer, OfflineMapLayer */

class MapFrame {

  constructor(containerId) {
    mapboxgl.accessToken = 'pk.eyJ1Ijoic3lkZXZhZG1pbiIsImEiOiJjazczcXV4ZzQwZXJtM3JxZTF6a2g0dW9hIn0.avMfkC306-2PqpNRnz6otg'
    this.mapbox = new mapboxgl.Map({
      container: containerId,
      style: 'mapbox://styles/sydevadmin/ck7g6nag70rn11io09f45odkq',
      minZoom: 1,
      dragRotate: false,
      //hash: true,
    })

    this.loadControlLayers()

    this.mapbox.on('load', _event => {
      this.layers = {
        //online: new OnlineMapLayer(this.mapbox),
        offline: new OfflineMapLayer(this.mapbox),
      }

      //this.showLayer('offline')
    })
  }

  loadControlLayers() {
    this.mapbox.addControl(new MapboxLanguage({ defaultLanguage: window.locale }))
    this.mapbox.addControl(new mapboxgl.NavigationControl({ showCompass: false }))

    const geolocater = new mapboxgl.GeolocateControl()
    this.mapbox.addControl(geolocater)

    geolocater.on('geolocate', event => {
      this.setLocation(event.coords, true)
    })
  }

  createEvents() {
    //window.addEventListener('resize', _event => this.updatePadding())
  }

  showLayer(layerName) {
    Object.entries(this.layers).forEach(function([key, layer]) {
      console.log('layer', key, '/', layer)
      layer.toggle(key == layerName)
    })
  }

  resize() {
    this.mapbox.resize()
  }

  destroy() {
    this.mapbox.remove()
  }

}