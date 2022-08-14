/* global $ */
/* exported OsmSearch */

const OsmSearch = {
  load() {
    this.$search = $('#js-osm-search')
    this.$input = $('#js-osm-search input')
    this.$submit = $('#js-osm-search .submit.button')
    this.$body = $('#js-osm-search table')

    const allowCustom = this.$search.data('custom') == 'true'
    const type = this.$search.data('type')
    let countryCode = this.$search.data('country')
    if (countryCode) countryCode = countryCode.toLowerCase()

    this.$submit.api({
      url: `https://nominatim.openstreetmap.org/search?q={query}&format=json&featuretype=${type}&countrycodes=${countryCode}`,
      beforeSend: (settings) => {
        console.log('beforeSend', settings)
        settings.urlData = { query: this.$input.val() }
        console.log('settings', settings)
        return settings
      },
      onSuccess: (response, test, test1) => {
        console.log('got osm', response, test, test1)
        this.$body.empty()
        for (const index in response) {
          const result = response[index]
          this.$body.append(`<tr><td>${result.display_name}</td><td class="right aligned"><a class="ui button" href=?osm_id=${result.osm_id}>${"Choose"}<i class="right arrow icon"></i></a></tr>`)
        }

        if (allowCustom) {
          this.$body.append(`<tr><td></td><td class="collapsing"><a class="ui button" href=?osm_id=custom><i class="vector square icon"></i>${"Custom Region"}<i class="right arrow icon"></i></a></tr>`)
        }
      }
    })
  },
}

$(document).on('ready', function() {
  if ($('#js-osm-search').length > 0) {
    OsmSearch.load()
  }
})
