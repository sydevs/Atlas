/* global $, L */
/* exported PreviewMap */

class PreviewMap {
  #container
  #data = {}
  #leaflet
  #inputs = {}
  #layer = null
  #border = null
  #bounds = null

  #defaultStyle = {
    color: '#2185d0',
    fillColor: '#2185d0',
    fillOpacity: 0.3,
  }

  constructor(container) {
    console.log('Loading PreviewMap') // eslint-disable-line no-console
    this.#container = container
    this.#data = container.dataset
    this.#leaflet = L.map(container.id, {
      attributionControl: false,
      zoomSnap: 0.25,
      zoomDelta: 0.5,
    })

    this.leaflet = this.#leaflet

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.#leaflet)

    if (this.#data.changeable || this.#data.editable) {
      const fields = ['latitude', 'longitude', 'radius', 'bounds', 'geojson']
      fields.forEach(field => {
        this.#inputs[field] = this.setupInput(field)
        if (!this.#inputs[field]) delete this.#inputs[field]
      })
    } else {
      this.#leaflet.scrollWheelZoom.disable()
    }

    this.#invalidate()
  }

  setupInput(field) {
    const input = document.getElementById(`js-map-${field}`)
    if (!input) return

    this.#data[field] = input.value

    input.addEventListener('change', event => {
      console.log('on change', field)
      this.#data[field] = event.currentTarget.value
      this.#invalidate()
    })

    input.addEventListener('keyup', event => {
      this.#data[field] = event.currentTarget.value
      this.#invalidate()
    })

    return input
  }

  invalidate() {
    Object.entries(this.#inputs).forEach(([key, input]) => {
      this.#data[key] = input.value
    })
    
    this.#invalidate()
  }

  #invalidate() {
    const data = this.#data

    if (data.latitude && data.longitude && data.radius) {
      this.setCircle(data.latitude, data.longitude, data.radius)
    } else if (data.latitude && data.longitude) {
      this.setPoint(data.latitude, data.longitude)
    } else if (data.editable && data.border) {
      this.setEditablePolygon(data.geojson, data.border)
    } else if (data.geojson) {
      this.setGeojson(data.geojson)
      if (data.bounds) this.setBounds(data.bounds)
    } else {
      return
    }

    if (data.border && !data.editable) {
      this.setBorder(data.border)
    }
  }

  setCircle(latitude, longitude, radius) {
    if (this.#layer) this.#layer.removeFrom(this.#leaflet)

    this.setHeight(360)

    this.#layer = L.circle([latitude, longitude], radius * 1000, this.#defaultStyle).addTo(this.#leaflet)

    const bounds = L.latLng(latitude, longitude).toBounds(parseFloat(radius) * 2000)
    this.#leaflet.fitBounds(bounds)
  }

  setPoint(latitude, longitude) {
    if (this.#layer) this.#layer.removeFrom(this.#leaflet)

    this.setHeight(240)

    this.#layer = L.marker([latitude, longitude]).addTo(this.#leaflet)
    this.#leaflet.setView([latitude, longitude], 13)
  }

  setGeojson(geojson) {
    if (this.#layer) this.#layer.removeFrom(this.#leaflet)

    this.setHeight(360)

    geojson = JSON.parse(geojson)
    this.#layer = L.geoJSON(geojson, this.#defaultStyle).addTo(this.#leaflet)
    this.#leaflet.fitBounds(this.#layer.getBounds(), { padding: [10, 10] })
  }

  setEditablePolygon(geojson = null, border = null) {
    let coordinates

    if (!this.#layer) {
      this.setHeight(420)

      if (geojson) {
        geojson = JSON.parse(geojson)
        coordinates = geojson['coordinates']
      } else {
        border = JSON.parse(border)
        const center = L.geoJSON(border).getBounds().getCenter()
        const padding = 1
        coordinates = [
          [center.lat - padding, center.lng - padding],
          [center.lat + padding, center.lng - padding],
          [center.lat + padding, center.lng + padding],
          [center.lat - padding, center.lng + padding],
        ]
      }

      this.#layer = new L.Polygon(coordinates).addTo(this.#leaflet)
      this.#layer.editing.enable()
      this.#layer.on('edit', () => {
        let bounds = this.#layer.getBounds()
        bounds = [bounds.getSouth(), bounds.getNorth(), bounds.getWest(), bounds.getEast()]
        this.#inputs.bounds.value = JSON.stringify(bounds)
        this.#inputs.geojson.value = JSON.stringify(this.#layer.toGeoJSON()['geometry'])
      })
      
      this.#leaflet.fitBounds(this.#layer.getBounds(), { padding: [100, 100] })
    } else if (geojson) {
      this.#layer.setLatLngs(geojson['coordinates'][0])
    }
  }
 
  setBorder(geojson) {
    if (this.#border) this.#border.removeFrom(this.#leaflet)

    geojson = JSON.parse(geojson)
    this.#border = L.geoJSON(geojson, {
      style: {
        color: 'black',
        opacity: 0.8,
        weight: 2,
        dashArray: '8, 8',
        fillOpacity: 0,
      }
    }).addTo(this.#leaflet)

    if (this.#data.error) {
      let bounds = this.#border.getBounds()
      bounds.extend(this.#layer.getBounds())
      this.#leaflet.fitBounds(bounds, { padding: [20, 20] })
    }
  }
 
  setBounds(bounds) {
    bounds = JSON.parse(bounds)
    const coordinates = [
      [bounds[0], bounds[2]],
      [bounds[1], bounds[2]],
      [bounds[1], bounds[3]],
      [bounds[0], bounds[3]],
    ]

    if (this.#bounds) {
      this.#bounds.setLatLngs(coordinates)
    } else {
      this.#bounds = new L.Polygon(coordinates, {
        color: 'black',
        opacity: 0.5,
        weight: 2,
        dashArray: '8, 8',
        fillOpacity: 0,
      }).addTo(this.#leaflet)
    }
  }

  disableInteractions() {
    this.#leaflet.dragging.disable()
    this.#leaflet.touchZoom.disable()
    this.#leaflet.doubleClickZoom.disable()
  }

  setHeight(height) {
    $(this.#container).css('min-height', `${height}px`).css('opacity', '1')
    this.#leaflet.invalidateSize()
  }
}

$(document).on('ready', function() {
  const map = document.getElementById('map')
  if (map) {
    PreviewMap.instance = new PreviewMap(map)
  }
})
