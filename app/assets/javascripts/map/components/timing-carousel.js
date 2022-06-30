/* exported TimingCarousel */
/* global m, Util, Flickity, luxon */

function TimingCarousel() {
  let flickity
  let selectedValue
  let timings

  return {
    oncreate: function(vnode) {
      if (timings.length > 1) {
        flickity = new Flickity('#timings', {
          setGallerySize: false,
          pageDots: false,
        })

        flickity.on('select', (index) => {
          selectedValue = timings[index]
          vnode.attrs.onselect(selectedValue)
        })

        flickity.resize()
      }

      vnode.attrs.onselect(selectedValue)
    },
    onremove: function() {
      if (flickity) {
        flickity.destroy()
      }
    },
    view: function(vnode) {
      const event = vnode.attrs.event
      timings = event.timing.upcomingDateTimes.map(datetime => datetime.setLocale(window.locale))
      selectedValue = timings[0]

      return m('div',
        m('.registration__timing__label',
          m('.registration__timing__text', Util.translate('registration.form.timing'))
        ),
        m('.registration__timing#timings',
          timings.map(function(date) {
            return m('.registration__timing__cell',
              m('.registration__timing__date',
                m('.registration__timing__day', date.toLocaleString({ weekday: 'long' })),
                m('.registration__timing__month', date.toLocaleString({ month: 'long', day: 'numeric' }))
              ),
              m('.registration__timing__time',
                m('.registration__timing__hour', date.toLocaleString(luxon.DateTime.TIME_SIMPLE))
                //m('.registration__timing__timezone', )
              )
            )
          })
        )
      )
    }
  }
}