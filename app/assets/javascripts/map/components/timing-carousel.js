/* exported TimingCarousel */
/* global m, Util, Flickity, luxon */

function TimingCarousel() {
  let flickity
  let selectedValue
  let timings

  return {
    oncreate: function() {
      if (timings.length > 1) {
        flickity = new Flickity('#timings', {
          setGallerySize: false,
          pageDots: false,
        })

        flickity.on('select', (index) => { selectedValue = timings[index] })
        flickity.resize()
      }
    },
    onremove: function() {
      flickity.destroy()
    },
    view: function(vnode) {
      const event = vnode.attrs
      timings = Util.parseEventTiming(event, 'occurrences').map(date => date.setLocale(window.locale))
      selectedValue = timings[0]

      return m('div',
        m('input', {
          type: 'hidden',
          name: 'startingAt',
          value: selectedValue.toISO().substring(0, 10),
        }),
        m('.registration__timing__label',
          m('.registration__timing__text', "I’D LIKE TO START ON:")
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