
const Map = {
  instance: null,
  initial_zoom: null,
  //data: null,
  markers: null,
  active_marker: null,

  load() {
    console.log('loading map.js')
    Map.instance = L.map('map', {
      attributionControl: false,
      zoomControl: false,
      gestureHandling: true,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(Map.instance)

    Map.event_template = $('.venue-events-item').remove()

    let markers = L.markerClusterGroup({
      spiderfyOnMaxZoom: true,
      showCoverageOnHover: true,
      zoomToBoundsOnClick: true,
    }).on('click', (event) => {
      Events.filterByVenue(event.layer.options.venue_id)
      Sidebar.openPanel('list')
      Map.highlightMarker(event.layer)
    })

    let icon = L.divIcon({
      className: 'marker',
      html: '<i class="large blue map marker alternate icon"></i>'
    })

    Map.markers = {}
    for (let id in Data.venues) {
      let item = Data.venues[id]
      Map.markers[id] = L.marker([item['latitude'], item['longitude']], {
        title: item['name'],
        //icon: icon,
        venue_id: id,
      }).addTo(markers)
    }

    Map.instance.addLayer(markers)
    //Map.instance.setView([0, 0], 2)
    Map.instance.fitBounds(markers.getBounds().pad(0.1))
    Map.initial_zoom = Map.instance.getZoom()

    L.control.zoom({ position: 'topright' }).addTo(Map.instance)
    L.control.sidebar({ container: 'sidebar' }).addTo(Map.instance)
    L.control.searchbox({ position: 'topleft' }).addTo(Map.instance)
  },

  reset() {
    Map.instance.setZoom(Map.initial_zoom)
    Map.highlightMarker(null)
  },

  highlightMarker(marker) {
    const targetZoom = 13

    if (Map.active_marker != null) {

    }

    Map.active_marker = marker

    if (Map.active_marker != null) {
      let overlayWidth = Number.parseInt(document.getElementById('sidebar').offsetWidth)
      let targetPoint = Map.instance.project(marker.getLatLng(), targetZoom).subtract([overlayWidth / 2, 0])
      let targetLatLng = Map.instance.unproject(targetPoint, targetZoom)
      Map.instance.setView(targetLatLng, targetZoom)
    }
  },
}
