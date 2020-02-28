/* global $, L */
/* exported VenueMap */

const VenueMap = {
  data: {},
  geocoder: null,
  instance: null,
  venueMarker: null,
  initialZoom: 13,

  load() {
    console.log('Loading VenueMap') // eslint-disable-line no-console

    VenueMap.data = $('#venue-map').data()
    VenueMap.instance = L.map('venue-map', {
      attributionControl: false,
      zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(VenueMap.instance)

    if (VenueMap.data.editable == true) {
      VenueMap.initEditableMap()
    } else {
      VenueMap.initPreviewMap()
    }
  },

  initEditableMap() {
    VenueMap.messages = $('.map.message')

    var latitude = $('#venue_latitude').val()
    var longitude = $('#venue_longitude').val()
    if (latitude != '' && longitude != '') {
      VenueMap.setMarker(latitude, longitude)
    }

    $('.lookup.button').click(VenueMap.onLookup)
    $('[name="venue[latitude]"], [name="venue[longitude]"]').change(() => {
      const latitude = $('[name="venue[latitude]"]').val()
      const longitude = $('[name="venue[longitude]"]').val()

      if (latitude && longitude) {
        VenueMap.setMarker(latitude, longitude)
      }
    })

    VenueMap.instance.dragging.disable()
  },

  initPreviewMap() {
    VenueMap.setMarker(VenueMap.data.latitude, VenueMap.data.longitude)
    VenueMap.instance.dragging.disable()
    VenueMap.instance.touchZoom.disable()
    VenueMap.instance.doubleClickZoom.disable()
    VenueMap.instance.scrollWheelZoom.disable()
  },

  setMarker(latitude, longitude) {
    if (!VenueMap.venueMarker) {
      VenueMap.venueMarker = L.marker().addTo(VenueMap.instance)
      VenueMap.venueMarker.on('click', VenueMap.onMarkerClick)
    }

    $('#venue-map').css('min-height', '180px').css('opacity', '1')
    VenueMap.venueMarker.setLatLng([latitude, longitude])
    VenueMap.instance.invalidateSize()
    VenueMap.instance.setView([latitude, longitude], VenueMap.initialZoom)

    if (VenueMap.messages) {
      VenueMap.messages.filter('.for-success').removeClass('hidden')
    }
  },

  onLookup(event) {
    let $button = $(event.target)
    $button.addClass('loading')

    $.ajax({
      url: '/cms/venues/geocode',
      type: 'GET',
      dataType: 'json',
      data: {
        query: VenueMap.parseAddress(),
        country_code: document.getElementById('venue_country_code').value,
      },
      success: function(data) {
        VenueMap.messages.addClass('hidden')
        $('#venue_latitude').val(data.latitude)
        $('#venue_longitude').val(data.longitude)
        $('#venue_place_id').val(data.place_id)
        VenueMap.setMarker(data.latitude, data.longitude)
        $button.removeClass('loading')
      },
      error: function(_data) {
        VenueMap.messages.addClass('hidden')
        VenueMap.messages.filter('.for-failure').removeClass('hidden')
        $button.removeClass('loading')
      },
    })
  },

  onMarkerClick() {
    const place_id = $('#venue_place_id').val()
    const latitude = $('#venue_latitude').val()
    const longitude = $('#venue_longitude').val()
    let url

    if (place_id) {
      url = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(VenueMap.parseAddress())}>&query_place_id=${place_id}`
    } else if (latitude && longitude) {
      url = `http://www.google.com/maps/place/${latitude},${longitude}`
    }

    if (url) {
      window.open(url, '_blank')
    }
  },

  parseAddress() {
    const addressField = document.getElementById('venue_address')

    if (addressField) {
      return addressField.value
    } else {
      return [
        document.getElementById('venue_street').value,
        document.getElementById('venue_city').value,
        document.getElementById('venue_province_code').value,
        document.getElementById('venue_country_code').value,
        document.getElementById('venue_postcode').value,
      ].filter(Boolean).join(', ')
    }
  },
}

$(document).on('ready', function() {
  if ($('#venue-map').length > 0) {
    VenueMap.load()
  }
})
