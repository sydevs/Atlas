/* global $ */
/* exported AreaSearch */

const AreaSearch = {
  load() {
    this.$search = $('#js-area-search')
    this.$name = $('#area_name')
    this.$latitude = $('#area_latitude')
    this.$longitude = $('#area_longitude')
    this.$radius = $('#area_radius')

    this.$latitude.change(() => this.onManualUpdate())
    this.$longitude.change(() => this.onManualUpdate())
    this.$radius.change(() => this.onManualUpdate())

    this.$search.search({
      minCharacters: 3,
      apiSettings: {
        url: `/cms/areas/geosearch?country=${this.$search.data('country')}&query={query}`,
      },
      onSelect: (result, _response) => {
        this.$name.val(result.structured_formatting.main_text)
        this.$search.search('set value', '')
        this.$search.search('display message', 'Retrieving data', 'message')
        this.fetchGeometry(result.place_id)
      }
    })
  },

  fetchGeometry(place_id) {
    $.ajax({
      url: '/cms/areas/geocode',
      type: 'GET',
      dataType: 'json',
      data: { place_id: place_id },
      success: (data) => {
        data.radius = data.radius.toFixed(2)
        data.latitude = data.latitude.toFixed(3)
        data.longitude = data.longitude.toFixed(3)

        this.disabledAutoUpdate = true

        if (this.mode == 'area') {
          this.$latitude.val(data.latitude)
          this.$longitude.val(data.longitude)
          this.$radius.val(data.radius)
        } else {
          this.$latitude.val(data.latitude)
          this.$longitude.val(data.longitude)
          this.$radius.val(data.radius)
        }

        this.disabledAutoUpdate = false
        RegionMap.setCircle(data.latitude, data.longitude, data.radius)
      },
      error: (data) => {
        this.$search.search('display message', data, 'message')
      },
    })
  },

  onManualUpdate() {
    if (this.disabledAutoUpdate) return

    const latitude = this.$latitude.val()
    const longitude = this.$longitude.val()
    const radius = this.$radius.val()
    RegionMap.setCircle(latitude, longitude, radius)
  }
}

$(document).on('ready', function() {
  if ($('#js-area-search').length > 0) {
    AreaSearch.load()
  }
})
