
const Map = {
  geocoder: null,
  instance: null,
  venue_marker: null,
  initial_view: null,
  initial_zoom: 13,

  search_button: null,

  load() {
    Map.instance = L.map('map', {
      attributionControl: false,
      zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(Map.instance)

    let page = document.body.className.split(/\s+/)
    if (page.includes('venues')) {
      if (page.includes('new') || page.includes('edit')) {
        Map.init_venue_editable_map()
      } else if (page.includes('show')) {
        Map.init_venue_preview_map()
      }
    }
  },

  init_venue_editable_map() {
    Map.messages = $('.map.message')
    Map.geocoder = new GeoSearch.OpenStreetMapProvider()

    var latitude = $('#venue_latitude').val()
    var longitude = $('#venue_longitude').val()
    if (latitude != '' && longitude != '') {
      Map.set_marker(latitude, longitude)
    }

    $('.lookup.button').click(Map._on_lookup)
    Map.instance.dragging.disable()
  },

  init_venue_preview_map() {
    Map.set_marker($('#map').data('latitude'), $('#map').data('longitude'))
    Map.instance.dragging.disable()
    Map.instance.touchZoom.disable()
    Map.instance.doubleClickZoom.disable()
    Map.instance.scrollWheelZoom.disable()
  },

  set_marker(latitude, longitude) {
    Map.venue_marker = L.marker([latitude, longitude]).addTo(Map.instance)
    $('#map').css('min-height', '180px').css('opacity', '1')
    Map.instance.invalidateSize()
    Map.instance.setView([latitude, longitude], Map.initial_zoom);
  },

  _on_lookup(event) {
    console.log('lookup marker')
    let $button = $(event.target)
    $button.addClass('loading')

    let value = [
      document.getElementById('venue_street').value,
      document.getElementById('venue_municipality').value,
      document.getElementById('venue_subnational').value,
      document.getElementById('venue_country_code').value,
      document.getElementById('venue_postcode').value,
    ].filter(Boolean).join(', ')

    console.log('Geocoding', value)

    Map.geocoder.search({
      query: value,
    }).then(function(results) {
      Map.messages.removeClass('active')

      if (results.length > 0) {
        var result = results[0]
        console.log(result)
        $('#venue_latitude').val(result.y)
        $('#venue_longitude').val(result.x)
        Map.set_marker(result.y, result.x)
        Map.messages.filter('.for-success').addClass('active')
      } else {
        Map.messages.filter('.for-failure').addClass('active')
      }

      $button.removeClass('loading')
    })
  },
}

$(document).on('ready', function() {
  if ($('#map').length > 0) {
    Map.load()
  }
})
