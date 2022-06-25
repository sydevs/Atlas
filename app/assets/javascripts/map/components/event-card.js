/* exported EventCard */
/* global m, Util */

function EventCard() {
  return {
    /*onbeforeremove: function(vnode) {
      vnode.dom.classList.add('fadeout')
      return new Promise(function(resolve) {
        vnode.dom.addEventListener('animationend', resolve)
      })
    },*/
    view: function(vnode) {
      const event = vnode.attrs.event
      let language = Util.translate(`language_codes.${event.languageCode.toLowerCase()}`) || event.languageCode
      let distance = event.layer == 'offline' && App.map.userLocation && event.distanceTo(App.map.userLocation)

      return m(m.route.Link,
        {
          class: `card ${vnode.attrs.class}`,
          href: '/:layer/:id',
          params: { layer: event.layer, id: event.id },
        },
        m('.card__content',
          m('.card__title', event.label),
          m('.card__subtitle',
            m('span', event.address),
            distance ? m('span', Util.translate('event.distance', { distance: distance })) : null,
          ),
          m('.card__meta',
            event.languageCode != window.locale ? m('.pill', language.toUpperCase()) : null,
            m('.card__meta__day', event.timing.dateString),
            m('.card__meta__time', event.timing.timeString),
            event.online ?
              null :
              m('abbr.card__meta__timezone', {
                'data-tooltip': event.timing.timeZone('long'),
              }, event.timing.timeZone('short')),
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
