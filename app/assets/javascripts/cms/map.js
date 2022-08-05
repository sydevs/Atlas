/* global $, L */
/* exported Map */

class Map {
  #container
  #data = {}
  #leaflet
  #inputs = {}
  #circle = null
  #point = null

  constructor(container) {
    console.log('Loading Map') // eslint-disable-line no-console
    this.#container = container
    this.#data = container.dataset
    this.#leaflet = L.map(container.id, {
      attributionControl: false,
      //zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.#leaflet)

    if (this.#data.editable) {
      const fields = ['latitude', 'longitude', 'radius']
      fields.forEach(field => {
        this.#inputs[field] = this.setupInput(field)
      })
    }

    this.#invalidate()
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
    }

    this.#leaflet.invalidateSize()
  }

  setCircle(latitude, longitude, radius) {
    if (!(latitude && longitude && radius)) {
      return
    }

    if (this.#point) this.#point.removeFrom(this.#leaflet)
    if (this.#circle) this.#circle.removeFrom(this.#leaflet)

    $(this.#container).css('min-height', '360px').css('opacity', '1')

    this.#circle = L.circle([latitude, longitude], radius * 1000, {
      color: '#2185d0',
      fillColor: '#2185d0',
      fillOpacity: 0.3,
    }).addTo(this.#leaflet)

    const bounds = L.latLng(latitude, longitude).toBounds(parseInt(radius) * 2000)
    this.#leaflet.fitBounds(bounds)
  }

  setPoint(latitude, longitude) {
    if (this.#circle) this.#circle.removeFrom(this.#leaflet)
    if (this.#point) this.#point.removeFrom(this.#leaflet)

    $(this.#container).css('min-height', '240px').css('opacity', '1')

    this.#point = L.marker([latitude, longitude]).addTo(this.#leaflet)
    this.#leaflet.setView([latitude, longitude], 13)

    /*if (VenueMap.messages) {
      VenueMap.messages.filter('.for-success').removeClass('hidden')
    }*/
  }

  disableInteractions() {
    this.#leaflet.dragging.disable()
    this.#leaflet.touchZoom.disable()
    this.#leaflet.doubleClickZoom.disable()
    this.#leaflet.scrollWheelZoom.disable()
  }
}

$(document).on('ready', function() {
  const map = document.getElementById('map')
  if (map) {
    Map.instance = new Map(map)
  }
})
