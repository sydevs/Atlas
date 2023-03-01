/* global $ */
/* exported General */

const General = {
  load: function() {
    $('select, .ui.dropdown:not(.ajax)').dropdown()
    $('.ui.accordion').accordion()
    $('.ui.checkbox').checkbox()
    $('.ui.menu .tab.item').tab()
    $('.ui.embed').embed()

    $('.start.field .ui.date.calendar').calendar({ type: 'date', endCalendar: $('.end.field .ui.date.calendar') })
    $('.end.field .ui.date.calendar').calendar({ type: 'date', startCalendar: $('.start.field .ui.date.calendar') })
    $('.start.field .ui.time.calendar').calendar({ type: 'time', ampm: false, endCalendar: $('.end.field .ui.time.calendar') })
    $('.end.field .ui.time.calendar').calendar({ type: 'time', ampm: false, startCalendar: $('.start.field .ui.time.calendar') })
    $('.field:not(.start):not(.end) .ui.date.calendar').calendar({ type: 'date' })
    $('.field:not(.start):not(.end) .ui.time.calendar').calendar({ type: 'time', ampm: false })

    $('.search').parent().submit(General.onSearchSubmit)
    $('.ui.radio.menu .item').click(General.onRadioMenuSelect)

    let $registration_mode = $('.event_registration_mode')
    let $registration_select = $('.event_registration_mode > .ui.selection')
    let $registration_url = $('.event_registration_url')
    let $registration_config = $('.event_registration_config')
    let onRegistrationModeSelect = (value) => {
      const visible = value != 'native'
      $registration_mode.toggleClass('four', visible)
      $registration_mode.toggleClass('sixteen', !visible)
      $registration_url.toggle(visible)
      $registration_config.toggle(!visible)
    }

    let value = $registration_select.dropdown('get value')
    onRegistrationModeSelect(value)
    $registration_select.dropdown({ onChange: onRegistrationModeSelect })

    $('.js-character-count').each((_index, counter) => {
      $(`#${counter.dataset.for}`).on('input', event => {
        const length = event.currentTarget.value.length
        counter.parentElement.style = (length != 0 && (length < counter.dataset.min || length > counter.dataset.max) ? 'color: darkred' : '')
        counter.innerText = length
      })
    })
  },

  onSearchSubmit: function() {
    const $input = $('.search > input')
    $input.siblings('.input').addClass('loading')
    $input.blur()

    var query = $input.closest('form').serialize()
    var url = window.location.protocol + '//' + window.location.host + window.location.pathname + '?' + query
    window.history.pushState({ path: url }, '', url)
  },

  onRadioMenuSelect: function() {
    const $item = $(this)
    $item.siblings('input').val($item.data('value'))
    $item.siblings('.active').removeClass('active')
    $item.addClass('active')
  },

  onRegistrationModeSelect: function(value) {
    const visible = value != 'native'
    $registration_mode.toggleClass('four', visible)
    $registration_mode.toggleClass('sixteen', !visible)
    $registration_url.toggle(visible)
  },
}

$(document).on('ready', function() { General.load() })
