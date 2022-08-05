/* global $ */
/* exported AreaSearch */

const AreaSearch = {
  load() {
    this.$search = $('#js-area-search')
    this.$name = $('#area_name')
    this.$latitude = $('#js-map-latitude')
    this.$longitude = $('#js-map-longitude')
    this.$radius = $('#js-map-radius')
    
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
        this.$latitude.val(data.latitude.toFixed(3)).trigger('change')
        this.$longitude.val(data.longitude.toFixed(3)).trigger('change')
        this.$radius.val(data.radius.toFixed(2)).trigger('change')

        if (Map.instance) Map.instance.invalidate()
      },
      error: (data) => {
        this.$search.search('display message', data, 'message')
      },
    })
  }
}

$(document).on('ready', function() {
  if ($('#js-area-search').length > 0) {
    AreaSearch.load()
  }
})
