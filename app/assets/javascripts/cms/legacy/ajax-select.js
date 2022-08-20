/* global $ */
/* exported AjaxSelect */

const AjaxSelect = {
  load: function() {
    const $country = $('#venue_country_code')
    const $region = $('#venue_province_code')

    $country.dropdown({
      apiSettings: { url: $country.data('url') },
      placeholder: $country.data('prompt'),
      filterRemoteData: true,
      ignoreDiacritics: true,
      onChange: (value, _text, _$selectedItem) => {
        const $dropdown = $region.parent()
        
        $dropdown.dropdown('clear')
        $dropdown.dropdown({
          apiSettings: { url: `${$region.data('url')}&country_code=${value}` },
          placeholder: $region.data('prompt'),
          filterRemoteData: true,
          ignoreDiacritics: true,
          saveRemoteData: false,
        })
        $dropdown.dropdown('restore placeholder text')
      }
    })

    $region.dropdown({
      apiSettings: { url: $region.data('url') },
      placeholder: $region.data('prompt'),
      filterRemoteData: true,
      ignoreDiacritics: true,
      saveRemoteData: false,
    })

    $country.dropdown('restore placeholder text')
    $region.dropdown('restore placeholder text')
  },
}

$(document).on('ready', function() { AjaxSelect.load() })
