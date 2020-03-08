/* global $ */
/* exported AjaxSelect */

const AjaxSelect = {
  load: function() {
    const $country = $('#venue_country_code')
    const $province = $('#venue_province_code')

    $country.dropdown({
      apiSettings: { url: $country.data('url') },
      filterRemoteData: true,
      ignoreDiacritics: true,
      onChange: (value, _text, _$selectedItem) => {
        const $dropdown = $province.parent()
        
        $dropdown.dropdown('clear')
        $dropdown.dropdown({
          apiSettings: { url: `${$province.data('url')}&country_code=${value}` },
          filterRemoteData: true,
          ignoreDiacritics: true,
          saveRemoteData: false,
        })
      }
    })

    $province.dropdown({
      apiSettings: { url: $province.data('url') },
      filterRemoteData: true,
      ignoreDiacritics: true,
      saveRemoteData: false,
    })
  },
}

$(document).on('ready', function() { AjaxSelect.load() })
