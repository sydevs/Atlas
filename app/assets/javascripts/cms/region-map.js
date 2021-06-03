/* global $, L */
/* exported RegionMap */

const RegionMap = {
  provinceDataUrl: 'assets/map-data/ne_10m_admin_1_states_provinces.zip',
  countriesDataUrl: 'assets/map-data/ne_110m_admin_0_countries_lakes.zip',
  instance: null,

  load() {
    console.log('Loading RegionMap') // eslint-disable-line no-console

    const $map = $('#region-map')
    RegionMap.data = $map.data()
    RegionMap.instance = L.map('region-map', {
      attributionControl: false,
      //zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(RegionMap.instance)
    $map.css('min-height', '360px').css('opacity', '1')

    if (RegionMap.data.editable == 'true') {
      RegionMap.initEditableMap()
    } else {
      RegionMap.initPreviewMap()
    }

    RegionMap.instance.invalidateSize()
  },

  initEditableMap() {
    console.error('Editable region map is not implemented as of yet') // eslint-disable-line no-console
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
      const bounds = L.latLng(data.latitude, data.longitude).toBounds(parseInt(data.radius) * 2000)
      RegionMap.instance.fitBounds(bounds)
    }
  },

  setCircle(latitude, longitude, radius) {
    RegionMap.circle = L.circle([latitude, longitude], radius * 1000, {
      color: '#2185d0',
      fillColor: '#2185d0',
      fillOpacity: 0.3,
    }).addTo(RegionMap.instance)
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
