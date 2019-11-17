
const DateInput = {
  input: null,
  days: {
    list: null,
    active: null,
  },
  month: {
    prev: null,
    current: null,
    next: null,
  },

  dates: null,
  month_index: null,

  load() {
    console.log('loading date.js')
    DateInput.input = L.DomUtil.get('register-date-input')
    DateInput.month.current = L.DomUtil.get('register-month-current')
    DateInput.month.prev = L.DomUtil.get('register-month-prev')
    DateInput.month.next = L.DomUtil.get('register-month-next')
    DateInput.days.list = L.DomUtil.get('register-day-list')

    DateInput.month.prev.addEventListener('click', DateInput.previousMonth)
    DateInput.month.next.addEventListener('click', DateInput.nextMonth)
    DateInput.days.list.addEventListener('click', DateInput._onClickDay)
  },

  setDates(dates) {
    DateInput.dates = dates
    DateInput.setActiveMonth(0)
  },

  previousMonth() {
    DateInput.setActiveMonth(DateInput.month_index - 1)
  },

  nextMonth() {
    DateInput.setActiveMonth(DateInput.month_index + 1)
  },

  setActiveMonth(index) {
    index = Math.min(Math.max(index, 0), DateInput.dates.length - 1)
    if (index == DateInput.month_index) return

    DateInput.month_index = index
    DateInput.month.current.innerText = DateInput.dates[DateInput.month_index][0]
    DateInput.input.value = ''
    DateInput.setActiveDayElement(null)

    html = ''
    let month_data = DateInput.dates[DateInput.month_index]
    for (let i = 1; i < month_data.length; i++) {
      html += '<div class="register-day">' + month_data[i] + '</div>'
    }

    if (DateInput.month_index == 0) {
      L.DomUtil.addClass(DateInput.month.prev, 'disabled')
    } else {
      L.DomUtil.removeClass(DateInput.month.prev, 'disabled')
    }

    if (DateInput.month_index == DateInput.dates.length - 1) {
      L.DomUtil.addClass(DateInput.month.next, 'disabled')
    } else {
      L.DomUtil.removeClass(DateInput.month.next, 'disabled')
    }

    DateInput.days.list.innerHTML = html
  },

  setActiveDayElement(day) {
    if (DateInput.days.active != null) {
      L.DomUtil.removeClass(DateInput.days.active, 'active')
    }

    DateInput.days.active = day

    if (DateInput.days.active != null) {
      L.DomUtil.addClass(DateInput.days.active, 'active')
    }
  },

  _onClickDay(event) {
    DateInput.input.value = event.target.innerText + ' ' + DateInput.month.current.innerText
    if (DateInput.days.active != null) L.DomUtil.removeClass(DateInput.days.active, 'active')
    L.DomUtil.addClass(event.target, 'active')
    DateInput.setActiveDayElement(event.target)
  },

}
