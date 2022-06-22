/* exported EventCard */
/* global m, Util */

function EventCard() {
  return {
    onbeforeremove: function(vnode) {
      vnode.dom.classList.add('fadeout')
      return new Promise(function(resolve) {
        vnode.dom.addEventListener('animationend', resolve)
      })
    },
    view: function(vnode) {
      const event = vnode.attrs.event
      let language = Util.translate(`language_codes.${event.languageCode.toLowerCase()}`) || event.languageCode

      return m(m.route.Link,
        {
          class: `card ${vnode.attrs.class}`,
          href: `/event/${event.id}`,
        },
        m('.card__content',
          m('.card__title', event.label),
          m('.card__subtitle',
            m('span', event.address),
            m('span', event.distance)
          ),
          m('.card__meta',
            event.languageCode != window.locale ? m('.pill', language) : null,
            m('.card__meta__day', Util.parseEventTiming(event, 'recurrence')),
            m('.card__meta__time', Util.parseEventTiming(event, 'duration')),
            !event.online ? m('abbr.card__meta__timezone', {
              'data-tooltip': Util.parseEventTiming(event, 'longTimeZone'),
            }, Util.parseEventTiming(event, 'shortTimeZone')) : null,
          )
        ),
        m('a.card__action',
          m('span', Util.translate('list.more_info')),
          m('i.icon.icon--right')
        )
      )
    }
  }
}
