
const VenueMap = {
  data: {},
  geocoder: null,
  instance: null,
  venueMarker: null,
  initialZoom: 13,

  load() {
    console.log("Loading VenueMap")

    VenueMap.data = $('#venue-map').data()
    VenueMap.instance = L.map('venue-map', {
      attributionControl: false,
      zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(VenueMap.instance)

    if (VenueMap.data['editable'] == 'true') {
      VenueMap.initEditableMap()
    } else {
      VenueMap.initPreviewMap()
    }
  },

  initEditableMap() {
    VenueMap.messages = $('.map.message')
    VenueMap.geocoder = new GeoSearch.OpenStreetMapProvider()

    var latitude = $('#venue_latitude').val()
    var longitude = $('#venue_longitude').val()
    if (latitude != '' && longitude != '') {
      VenueMap.setMarker(latitude, longitude)
    }

    $('.lookup.button').click(VenueMap.onLookup)
    VenueMap.instance.dragging.disable()
  },

  initPreviewMap() {
    VenueMap.setMarker(VenueMap.data['latitude'], VenueMap.data['longitude'])
    VenueMap.instance.dragging.disable()
    VenueMap.instance.touchZoom.disable()
    VenueMap.instance.doubleClickZoom.disable()
    VenueMap.instance.scrollWheelZoom.disable()
  },

  setMarker(latitude, longitude) {
    VenueMap.venueMarker = L.marker([latitude, longitude]).addTo(VenueMap.instance)
    $('#venue-map').css('min-height', '180px').css('opacity', '1')
    VenueMap.instance.invalidateSize()
    VenueMap.instance.setView([latitude, longitude], VenueMap.initialZoom)
  },

  onLookup(event) {
    console.log('lookup marker')
    let $button = $(event.target)
    $button.addClass('loading')

    let value = [
      document.getElementById('venue_street').value,
      document.getElementById('venue_city').value,
      document.getElementById('venue_province').value,
      document.getElementById('venue_country_code').value,
      document.getElementById('venue_postcode').value,
    ].filter(Boolean).join(', ')

    console.log('Geocoding', value)

    VenueMap.geocoder.search({
      query: value,
    }).then(function(results) {
      VenueMap.messages.addClass('hidden')

      if (results.length > 0) {
        var result = results[0]
        console.log(result)
        $('#venue_latitude').val(result.y)
        $('#venue_longitude').val(result.x)
        VenueMap.setMarker(result.y, result.x)
        VenueMap.messages.filter('.for-success').removeClass('hidden')
      } else {
        VenueMap.messages.filter('.for-failure').removeClass('hidden')
      }

      $button.removeClass('loading')
    })
  },
}

$(document).on('ready', function() {
  if ($('#venue-map').length > 0) {
    VenueMap.load()
  }
})
