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
        //url: `/cms/venues/autocomplete?country=${this.$search.data('country')}&query={query}`,
        //url: '//maps.googleapis.com/maps/api/place/autocomplete/json?input={query}&key={key}',
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

        data = {
          place_id: result.place_id,
          address: result.description,
        }

        this.$inputs.each((index, field) => {
          if (field.name == 'event[venue][id]') {
            field.value = data.id
          } else {
            console.log('field', index, field)
            //const key = field.name.match(/^event\[venue_attributes\]\[(.+)\]$/)[1]
            console.log(field.name.match(/^event\[venue_attributes\]\[(.+)\]$/))
            const key = field.name.match(/^event\[venue_attributes\]\[(.+)\]$/)[1]
            field.value = data[key] || field.dataset.default || ''
            //$(field).prop('disabled', key == 'id')
          }
        })

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
        data.latitude = data.latitude.toFixed(6)
        data.longitude = data.longitude.toFixed(6)
        this.$latitude.val(data.latitude)
        this.$longitude.val(data.longitude)
        //RegionMap.setCircle(data.latitude, data.longitude, data.radius)
      },
      error: (data) => {
        this.$search.search('display message', data, 'message')
      },
    })
  }
}

$(document).on('ready', function() {
  if ($('#js-venue-search').length > 0) {
    VenueSearch.load()
  }
})
