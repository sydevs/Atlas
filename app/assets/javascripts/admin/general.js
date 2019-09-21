
const General = {
  load: function() {
    $('select, .ui.dropdown').dropdown()
    $('.ui.checkbox').checkbox()
    $('.ui.menu .tab.item').tab()

    $('.start.field .ui.date.calendar').calendar({ type: 'date', minDate: new Date(), endCalendar: $('.end.field .ui.date.calendar') })
    $('.end.field .ui.date.calendar').calendar({ type: 'date', minDate: new Date(), startCalendar: $('.start.field .ui.date.calendar') })
    $('.start.field .ui.time.calendar').calendar({ type: 'time', ampm: false, endCalendar: $('.end.field .ui.time.calendar') })
    $('.end.field .ui.time.calendar').calendar({ type: 'time', ampm: false, startCalendar: $('.start.field .ui.time.calendar') })

    $('#search').parent().submit(General.onSearchSubmit)
    $('.ui.radio.menu .item').click(General.onRadioMenuSelect)
  },

  onSearchSubmit: function() {
    $search = $('#search')
    $input = $search.children('input')
    $search.addClass('loading')
    $input.blur()

    var url = window.location.protocol + "//" + window.location.host + window.location.pathname + '?q=' + $input.val()
    window.history.pushState({ path: url }, '', url);
  },

  onRadioMenuSelect: function() {
    $item = $(this)
    console.log($item)
    $item.siblings('input').val($item.data('value'))
    $item.siblings('.active').removeClass('active')
    $item.addClass('active')
  },
}

$(document).on('ready', function() { General.load() })
