/* global $ */
/* exported AjaxSelect */

const AjaxSelect = {
  load: function() {
    const $country = $('#venue_country_code')
    const $province = $('#venue_province_code')

    $country.dropdown({
      apiSettings: { url: $country.data('url') },
      filterRemoteData: true,
      onChange: (value, _text, _$selectedItem) => {
        const $dropdown = $province.parent()
        
        $dropdown.dropdown('clear')
        $dropdown.dropdown({
          apiSettings: { url: `${$province.data('url')}&country_code=${value}` },
          filterRemoteData: true,
        })
      }
    })

    $province.dropdown({
      apiSettings: { url: $province.data('url') },
      filterRemoteData: true,
    })
  },
}

$(document).on('ready', function() { AjaxSelect.load() })
