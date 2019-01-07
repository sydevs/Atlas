
const Map = {
  instance: null,
  initial_zoom: null,
  data: null,

  load() {
    console.log('loading map.js')
    Map.instance = L.map('map', {
      attributionControl: false,
      zoomControl: false,
      gestureHandling: true,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(Map.instance)
    Map.event_template = $('.venue-events-item').remove()
    Sidebar.init()

    let markers = L.markerClusterGroup({
      spiderfyOnMaxZoom: true,
      showCoverageOnHover: true,
      zoomToBoundsOnClick: true,
    }).on('click', (event) => {
      Sidebar.show_venue(Map.data[event.layer.options.venue_id])
      Map.set_highlight_marker(event.layer, true)
    })

    let icon = L.divIcon({
      className: 'marker',
      html: '<i class="large blue map marker alternate icon"></i>'
    })

    Map.data = $('#map').data('markers')
    for (let id in Map.data) {
      let item = Map.data[id]
      Map.data[id]['marker'] = L.marker([item['latitude'], item['longitude']], {
        title: item['name'],
        //icon: icon,
        venue_id: id,
      }).addTo(markers)
    }

    Map.instance.addLayer(markers)
    //Map.instance.setView([0, 0], 2)
    Map.instance.fitBounds(markers.getBounds().pad(0.1))
    Map.initial_zoom = Map.instance.getZoom()
  },

  zoom_in() {
    Map.instance.setZoom(Map.instance.getZoom() + 1)
  },

  zoom_out() {
    Map.instance.setZoom(Map.instance.getZoom() - 1)
  },

  reset() {
    Map.instance.setZoom(Map.initial_zoom)
  },

  set_highlight_marker(marker, highlight) {
    if (highlight) {
      let overlayWidth = Number.parseInt($('.leaflet-sidebar').css('max-width'))
      let targetZoom = 13
      let targetPoint = Map.instance.project(marker.getLatLng(), targetZoom).subtract([overlayWidth / 2, 0])
      let targetLatLng = Map.instance.unproject(targetPoint, targetZoom)
      Map.instance.setView(targetLatLng, targetZoom)
    }
  },
}

$(document).on('ready', function() { Map.load() })
