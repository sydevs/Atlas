/* global $ */
/* exported OsmSearch */

const OsmSearch = {
  load() {
    this.$search = $('#js-osm-search')
    this.$input = $('#js-osm-search input')
    this.$submit = $('#js-osm-search .submit.button')
    this.$body = $('#js-osm-search table')

    const allowCustom = this.$search.data('custom')
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
      onSuccess: (response) => {
        console.log('got osm', response)
        this.$body.empty()

        if (response.length > 0) {
          for (const index in response) {
            const result = response[index]
            this.$body.append(`<tr><td>${result.display_name}</td><td class="collapsing right aligned"><a class="ui button" href=?osm_id=${result.osm_id}>${"Choose"}<i class="right arrow icon"></i></a></tr>`)
          }
        } else {
          this.$body.append(`<tr class="negative"><td colspan=2><i class="exclamation circle icon"></i>${this.$body.data('empty')}</td></tr>`)
        }

        if (allowCustom) {
          this.$body.append(`<tr><td></td><td class="collapsing"><a class="ui button" href="?osm_id=0"><i class="vector square icon"></i>${"Custom Region"}<i class="right arrow icon"></i></a></tr>`)
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
