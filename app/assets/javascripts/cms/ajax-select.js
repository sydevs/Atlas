/* global $ */
/* exported AjaxSelect */

const AjaxSelect = {
  load: function() {
    const $country = $('#venue_country_code')
    const $province = $('#venue_province_code')

    $country.dropdown({
      apiSettings: { url: $country.data('url') },
      placeholder: $country.data('prompt'),
      filterRemoteData: true,
      ignoreDiacritics: true,
      onChange: (value, _text, _$selectedItem) => {
        const $dropdown = $province.parent()
        
        $dropdown.dropdown('clear')
        $dropdown.dropdown({
          apiSettings: { url: `${$province.data('url')}&country_code=${value}` },
          placeholder: $province.data('prompt'),
          filterRemoteData: true,
          ignoreDiacritics: true,
          saveRemoteData: false,
        })
        $dropdown.dropdown('restore placeholder text')
      }
    })

    $province.dropdown({
      apiSettings: { url: $province.data('url') },
      placeholder: $province.data('prompt'),
      filterRemoteData: true,
      ignoreDiacritics: true,
      saveRemoteData: false,
    })

    $country.dropdown('restore placeholder text')
    $province.dropdown('restore placeholder text')
  },
}

$(document).on('ready', function() { AjaxSelect.load() })
