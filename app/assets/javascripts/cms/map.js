/* global $, L */
/* exported Map */

class Map {
  #container
  #data = {}
  #leaflet
  #inputs = {}
  #layer = null
  #border = null

  constructor(container) {
    console.log('Loading Map') // eslint-disable-line no-console
    this.#container = container
    this.#data = container.dataset
    this.#leaflet = L.map(container.id, {
      attributionControl: false,
      zoomSnap: 0.25,
      zoomDelta: 0.5,
    })

    this.leaflet = this.#leaflet

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.#leaflet)

    if (this.#data.editable) {
      const fields = ['latitude', 'longitude', 'radius', 'geojson']
      fields.forEach(field => {
        this.#inputs[field] = this.setupInput(field)
        if (!this.#inputs[field]) delete this.#inputs[field]
      })
    }

    if (this.#data.polygon) {
      this.setupPolygonDraw()
    } else if (!this.#data.editable) {
      this.#leaflet.scrollWheelZoom.disable()
    }

    this.#invalidate()
  }

  setupPolygonDraw() {
    this.#layer = new L.Polygon([
			[51.51, -0.1],
			[51.5, -0.06],
			[51.52, -0.03],
		]).addTo(this.#leaflet)

    this.#layer.editing.enable()

    this.setHeight(360)
    this.#leaflet.fitBounds(this.#layer.getBounds(), { padding: [20, 20] })

    const fields = ['bounds', 'geojson']
    fields.forEach(field => {
      this.#inputs[field] = document.getElementById(`js-map-${field}`)
    })

    this.#layer.on('edit', () => {
      let bounds = this.#layer.getBounds()
      bounds = [bounds.getSouth(), bounds.getNorth(), bounds.getWest(), bounds.getEast()]
			this.#inputs.bounds.value = JSON.stringify(bounds)
      this.#inputs.geojson.value = JSON.stringify(this.#layer.toGeoJSON()['geometry'])
		})
  }

  setupInput(field) {
    const input = document.getElementById(`js-map-${field}`)
    if (!input) return

    this.#data[field] = input.value
    input.addEventListener('change', event => {
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
    } else if (data.geojson) {
      this.setGeojson(data.geojson)
    } else {
      return
    }

    if (data.border) {
      this.setBorder(data.border)
    }
  }

  setCircle(latitude, longitude, radius) {
    if (this.#layer) this.#layer.removeFrom(this.#leaflet)

    this.setHeight(360)

    this.#layer = L.circle([latitude, longitude], radius * 1000, {
      color: '#2185d0',
      fillColor: '#2185d0',
      fillOpacity: 0.3,
    }).addTo(this.#leaflet)

    const bounds = L.latLng(latitude, longitude).toBounds(parseFloat(radius) * 2000)
    this.#leaflet.fitBounds(bounds)
  }

  setPoint(latitude, longitude) {
    if (this.#layer) this.#layer.removeFrom(this.#leaflet)

    this.setHeight(240)

    this.#layer = L.marker([latitude, longitude]).addTo(this.#leaflet)
    this.#leaflet.setView([latitude, longitude], 13)

    /*if (VenueMap.messages) {
      VenueMap.messages.filter('.for-success').removeClass('hidden')
    }*/
  }

  setGeojson(geojson) {
    if (this.#layer) this.#layer.removeFrom(this.#leaflet)

    this.setHeight(360)

    geojson = JSON.parse(geojson)
    this.#layer = L.geoJSON(geojson, {
      color: '#2185d0',
      fillColor: '#2185d0',
      fillOpacity: 0.3,
    }).addTo(this.#leaflet)
    this.#leaflet.fitBounds(this.#layer.getBounds(), { padding: [10, 10] })
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
    Map.instance = new Map(map)
  }
})
