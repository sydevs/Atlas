/* global $ */
/* exported VenueSearch */

const VenueSearch = {
  load() {
    this.$card = $('#js-venue-card')
    this.$search = $('#js-venue-search')
    this.$fields = $('#js-venue-fields')
    this.$inputs = $('#js-venue-fields [name]')
    this.$latitude = $('#event_venue_attributes_latitude')
    this.$longitude = $('#event_venue_attributes_longitude')

    this.$search.search({
      //type: 'category',
      minCharacters: 3,
      apiSettings: {
        url: `/cms/venues/geosearch?query={query}`,
        urlData: {
          key: 'AIzaSyAO7puRR_rzbuFoD-Wqtb3Ggv5pYxeomgs',
        },
      },
      onSelect: (result, _response) => {
        console.log('got search results', result)
        this.$card.find('.header').text(result.structured_formatting.main_text)
        this.$card.find('.meta').text(result.structured_formatting.secondary_text)

        this.$search.search('set value', '')
        this.$search.search('hide results')
        this.$search.removeClass('loading')

        this.fetchGeometry(result.place_id)
        this.$card.show()
        return false
      }
    })
  },

  fetchGeometry(place_id) {
    $.ajax({
      url: '/cms/venues/geocode',
      type: 'GET',
      dataType: 'json',
      data: { place_id: place_id },
      success: (data) => {
        this.setInputs(data)

        if (PreviewMap.instance) PreviewMap.instance.invalidate()
      },
      error: (data) => {
        this.$search.search('display message', data, 'message')
      },
    })
  },

  setInputs(data) {
    this.$inputs.each((index, field) => {
      const key = field.name.match(/^event\[venue_attributes\]\[(.+)\]$/)[1]
      field.value = data[key] || field.dataset.default || ''
    })
  },
}

$(document).on('ready', function() {
  if ($('#js-venue-search').length > 0) {
    VenueSearch.load()
  }
})
