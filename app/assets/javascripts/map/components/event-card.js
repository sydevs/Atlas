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
      let distance = event.offline && AtlasApp.map.userLocation && event.distanceTo(AtlasApp.map.userLocation)
      
      return m(m.route.Link,
        {
          class: `sya-card ${vnode.attrs.class}`,
          href: '/:layer/event/:id',
          params: { layer: event.layer, id: event.id },
        },
        m('.sya-card__content',
          m('.sya-card__title', event.label),
          m('.sya-card__subtitle',
            m('span.sya-card__subtitle__address', event.address),
            distance ? m('span.sya-card__subtitle__distance', Util.translate('event.distance', { distance: distance })) : null,
          ),
          m('.sya-card__meta',
            event.languageCode != AtlasApp.config.locale ? m('.sya-pill', language.toUpperCase()) : null,
            m('.sya-card__meta__day', event.timing.dateString),
            m('.sya-card__meta__time', event.timing.timeString),
            event.online ?
              null :
              m('abbr.sya-card__meta__timezone', {
                'data-tooltip': event.timing.timeZone('long'),
              }, event.timing.timeZone('short')),
            event.timing.startingSoon ? m('.sya-pill', Util.translate('event.upcoming')) : null,
          ),
        ),
        m('a.sya-card__action',
          m('span', Util.translate('list.more_info')),
          m('i.sya-icon.sya-icon--right')
        )
      )
    }
  }
}
