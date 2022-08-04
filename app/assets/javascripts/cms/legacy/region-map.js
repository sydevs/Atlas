/* global $, L */
/* exported RegionMap */

const RegionMap = {
  provinceDataUrl: 'assets/map-data/ne_10m_admin_1_states_provinces.zip',
  countriesDataUrl: 'assets/map-data/ne_110m_admin_0_countries_lakes.zip',
  instance: null,

  load() {
    console.log('Loading RegionMap') // eslint-disable-line no-console

    RegionMap.$container = $('#region-map')
    RegionMap.data = RegionMap.$container.data()
    RegionMap.instance = L.map('region-map', {
      attributionControl: false,
      //zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(RegionMap.instance)

    if (RegionMap.data.editable == true) {
      RegionMap.initEditableMap()
    } else {
      RegionMap.initPreviewMap()
    }

    RegionMap.instance.invalidateSize()
  },

  initEditableMap() {
    var radius = $('#area_radius').val()
    var latitude = $('#area_latitude').val()
    var longitude = $('#area_longitude').val()
    RegionMap.setCircle(latitude, longitude, radius)
  },

  initPreviewMap() {
    const data = RegionMap.data
    RegionMap.instance.invalidateSize()
    //RegionMap.disableInteractions()

    if (data.country) {
      RegionMap.loadCountryVectors()
      RegionMap.instance.setView([40, 0], 1.25)
    } else if (data.province) {
      RegionMap.loadSubnationalVectors()
      RegionMap.instance.setView([40, 0], 1.25)
    } else {
      RegionMap.setCircle(data.latitude, data.longitude, data.radius)
    }

    RegionMap.$container.css('min-height', '360px').css('opacity', '1')
  },

  setCircle(latitude, longitude, radius) {
    if (latitude == '' || longitude == '' || radius == '') {
      return
    }

    if (RegionMap.circle) {
      RegionMap.circle.removeFrom(RegionMap.instance)
    }

    RegionMap.$container.css('min-height', '360px').css('opacity', '1')

    RegionMap.circle = L.circle([latitude, longitude], radius * 1000, {
      color: '#2185d0',
      fillColor: '#2185d0',
      fillOpacity: 0.3,
    }).addTo(RegionMap.instance)

    const bounds = L.latLng(latitude, longitude).toBounds(parseInt(radius) * 2000)
    RegionMap.instance.fitBounds(bounds)
  },

  setCountry(country) {
    RegionMap.country = country
  },

  setSubnational(province) {
    RegionMap.province = province
  },

  loadCountryVectors() {
    console.log('loading country features', RegionMap.countriesDataUrl)
    RegionMap.countries = new L.Shapefile(RegionMap.countriesDataUrl, {
      onEachFeature: function(feature, layer) {
        console.log('loaded feature', feature, layer)
      }
    })
    RegionMap.countries.addTo(RegionMap.instance)
    RegionMap.countries.once('data:loaded', function() {
      console.log('finished loaded shapefile')
    })
  },

  loadSubnationalVectors() {
    console.log('loading province features', RegionMap.provinceDataUrl)
    RegionMap.provinces = new L.Shapefile(RegionMap.provinceDataUrl, {
      onEachFeature: function(feature, layer) {
        console.log('loaded feature', feature, layer)
      }
    })
    RegionMap.provinces.addTo(RegionMap.instance)
    RegionMap.provinces.once('data:loaded', function() {
      console.log('finished loaded shapefile')
    })
  },

  disableInteractions() {
    RegionMap.instance.dragging.disable()
    RegionMap.instance.touchZoom.disable()
    RegionMap.instance.doubleClickZoom.disable()
    RegionMap.instance.scrollWheelZoom.disable()
  },
}

$(document).on('ready', function() {
  if ($('#region-map').length > 0) {
    RegionMap.load()
  }
})
