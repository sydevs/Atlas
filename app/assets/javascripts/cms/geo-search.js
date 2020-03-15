/* global $ */
/* exported GeoSearch */

const GeoSearch = {
  load: function() {
    this.$search = $('.ui.area.search')
    if (this.$search.length > 0) {
      this.mode = 'area'
      this.loadAreaSearch()
      return
    }

    // Unfortunately this doesn't return consistent results, and so is currently disabled
    /*
    this.$search = $('.ui.venue.search')
    if (this.$search.length > 0) {
      this.mode = 'venue'
      this.loadVenueSearch()
      return
    }
    */
  },

  loadAreaSearch: function() {
    this.$name = $('#local_area_name')
    this.$latitude = $('#local_area_latitude')
    this.$longitude = $('#local_area_longitude')
    this.$radius = $('#local_area_radius')

    this.$search.search({
      minCharacters: 3,
      apiSettings: {
        url: `/cms/local_areas/autocomplete?country=${this.$search.data('country')}&query={query}`,
      },
      onSelect: (result, _response) => {
        this.$name.val(result.structured_formatting.main_text)
        this.$search.search('set value', '')
        this.$search.search('display message', 'Retrieving data', 'message')
        this.fetchGeometry(result.place_id)
      }
    })
  },

  loadVenueSearch: function() {
    this.$name = $('#venue_name')
    this.$street = $('#venue_street')
    this.$city = $('#venue_city')
    this.$province = $('#venue_province_code')
    this.$country = $('#venue_country_code')
    this.$postcode = $('#venue_postcode')

    this.$search.search({
      minCharacters: 3,
      apiSettings: {
        url: `/cms/venues/autocomplete?country=${this.$search.data('country')}&query={query}`,
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
      url: '/cms/local_areas/autocomplete',
      type: 'GET',
      dataType: 'json',
      data: { place_id: place_id },
      success: (data) => {
        if (this.mode == 'area') {
          this.$latitude.val(data.latitude)
          this.$longitude.val(data.longitude)
          this.$radius.val(data.radius)
        } else {
          this.$latitude.val(data.latitude)
          this.$longitude.val(data.longitude)
          this.$radius.val(data.radius)

        }
      },
      error: (data) => {
        this.$search.search('display message', data, 'message')
      },
    })
  },
}

$(document).on('ready', function() { GeoSearch.load() })
