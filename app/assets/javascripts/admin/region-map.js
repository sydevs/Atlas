
const RegionMap = {
  subnationalDataUrl: 'assets/map-data/ne_10m_admin_1_states_provinces.zip',
  countriesDataUrl: 'assets/map-data/ne_110m_admin_0_countries_lakes.zip',
  instance: null,

  load() {
    console.log("Loading RegionMap")

    const $map = $('#region-map')
    RegionMap.data = $map.data()
    RegionMap.instance = L.map('region-map', {
      attributionControl: false,
      zoomControl: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(RegionMap.instance)

    if (RegionMap.data['editable'] == 'true') {
      RegionMap.initEditableMap()
    } else {
      RegionMap.initPreviewMap()
    }

    $map.css('min-height', '360px').css('opacity', '1')
    RegionMap.instance.invalidateSize()
    console.log('Region map data', RegionMap.data)
  },

  initEditableMap() {
    console.error("Editable region map is not implemented as of yet")
  },

  initPreviewMap() {
    const data = RegionMap.data
    if (data.country) {
      RegionMap.loadCountryVectors()
      RegionMap.instance.setView([40, 0], 1.25)
    } else if (data.subnational) {
      RegionMap.loadSubnationalVectors()
      RegionMap.instance.setView([40, 0], 1.25)
    } else {
      RegionMap.setCircle(data.latitude, data.longitude, data.radius)
      RegionMap.instance.setView([data.latitude, data.longitude], 9)
    }

    RegionMap.instance.invalidateSize()
    RegionMap.disableInteractions()
  },

  setCircle(latitude, longitude, radius) {
    RegionMap.circle = L.circle([latitude, longitude], radius * 1000, {
      color: 'red',
      fillColor: '#f03',
      fillOpacity: 0.3
    }).addTo(RegionMap.instance)
  },

  setCountry(country) {
    RegionMap.country = country
  },

  setSubnational(subnational) {
    RegionMap.subnational = subnational
  },

  loadCountryVectors() {
    console.log('loading country features', RegionMap.countriesDataUrl)
    RegionMap.countries = new L.Shapefile(RegionMap.countriesDataUrl, {
			onEachFeature: function(feature, layer) {
				console.log('loaded feature', feature, layer)
			}
    })
    RegionMap.countries.addTo(RegionMap.instance)
    RegionMap.countries.once("data:loaded", function() {
			console.log("finished loaded shapefile");
		})
  },

  loadSubnationalVectors() {
    console.log('loading subnation features', RegionMap.subnationalDataUrl)
    RegionMap.subnations = new L.Shapefile(RegionMap.subnationalDataUrl, {
			onEachFeature: function(feature, layer) {
				console.log('loaded feature', feature, layer)
			}
    })
    RegionMap.subnations.addTo(RegionMap.instance)
    RegionMap.subnations.once("data:loaded", function() {
			console.log("finished loaded shapefile");
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
