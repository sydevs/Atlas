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

    $('.search').parent().submit(General.onSearchSubmit)
    $('.ui.radio.menu .item').click(General.onRadioMenuSelect)

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

    var url = window.location.protocol + '//' + window.location.host + window.location.pathname + '?q=' + $input.val()
    window.history.pushState({ path: url }, '', url)
  },

  onRadioMenuSelect: function() {
    const $item = $(this)
    $item.siblings('input').val($item.data('value'))
    $item.siblings('.active').removeClass('active')
    $item.addClass('active')
  },
}

$(document).on('ready', function() { General.load() })
