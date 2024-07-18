/* exported EventCard */
/* global m, Util */

function EventCard() {
  function onMouseOver(event) {
    if (MapInstance) {
      if (event && event.offline) {
        MapInstance.showHighlightMarker(event.location)
      } else {
        MapInstance.showHighlightMarker(null)
      }
    }
  }

  return {
    /*onbeforeremove: function(vnode) {
      vnode.dom.classList.add('fadeout')
      return new Promise(function(resolve) {
        vnode.dom.addEventListener('animationend', resolve)
      })
    },*/
    view: function(vnode) {
      const event = vnode.attrs.event
      //let language = Util.translate(`language_codes.${event.languageCode.toLowerCase()}`) || event.languageCode
      let distance = event.offline && AtlasApp.map.userLocation && event.distanceTo(AtlasApp.map.userLocation)
      let layer = event.online ? 'online' : 'offline'

      return m(m.route.Link,
        {
          class: `sya-card sya-card--${layer} ${vnode.attrs.class}`,
          onmouseover: () => { onMouseOver(event) },
          onmouseout: () => { onMouseOver(null) },
          href: '/event/:id',
          params: { id: event.id },
        },
        m('.sya-card__content',
          m('.sya-card__title', event.label),
          m('.sya-card__subtitle',
            m('span.sya-card__subtitle__address', event.address),
            distance ? m('span.sya-card__subtitle__distance', Util.translate('event.distance', { distance: distance })) : null,
          ),
          event.category == 'inactive' ? 
            m('.sya-card__meta', Util.translate('event.inactive.dates').toUpperCase()) :
            m('.sya-card__meta', m('.sya-card__meta__day', event.timing.dateString)),
            m('.sya-card__meta',
              m('.sya-card__meta__time', event.timing.startTime),
              event.online ?
                null :
                m('abbr.sya-card__meta__timezone', {
                  'data-tooltip': event.timing.timeZone('long'),
                }, event.timing.timeZone('short')),
            ),
            m('.sya-card__meta',
              event.timing.startingString && m('.sya-pill', event.timing.startingString),
              event.online && m('.sya-pill.sya-pill--online', Util.translate('event.online_text').toUpperCase()),
              event.timing.startingSoon && m('.sya-pill.sya-pill--soon', Util.translate('event.upcoming')),
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
