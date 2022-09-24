/* exported EventInfo */
/* global m, Util */

function EventInfo() {
  return {
    view: function(vnode) {
      const event = vnode.attrs
      let language = Util.translate(`languages.${event.languageCode.toUpperCase()}`).split(/[,;]/)[0]

      return [
        m('.sya-event',
          event.languageCode != AtlasApp.config.locale ? m('.sya-event__sidebar',
            m('.sya-event__sidebar__language', [
              m('div', Util.translate('event.language')),
              m('.sya-event__sidebar__language-text', language),
            ])
          ) : null,
          m('.sya-event__label', event.label),
          m('.sya-event__subtitle',
            event.online ?
              m('.sya-event__subtitle__online', Util.translate('event.online')) :
              null,
            m('.sya-event__subtitle__address', event.online ? Util.translate('event.online_from', { city: event.address }) : event.address)
          ),
          m('.sya-event__meta',
            m('.sya-event__meta__day', event.timing.dateString),
            m('.sya-event__meta__time', event.timing.timeString),
            event.online ?
              null :
              m('abbr.sya-card__meta__timezone', {
                'data-tooltip': event.timing.timeZone('long'),
              }, event.timing.timeZone('short'))
          ),
          event.phoneNumber ? m('a.sya-event__phone',
            m('span.sya-event__phone__number', {
              'data-prefix': Util.translate('event.tel') + ': ',
            }, event.phoneNumber),
            m('span.event__phone__name', event.phoneName)
          ) : null
        ),
        m('.sya-event__actions',
          m('a',
            {
              tabindex: 1,
              href: '#registration',
            },
            m('span.sya-icon.sya-icon--signup'),
            m('span', Util.translate('event.register'))
          ),
          event.location.directionsUrl ? m('a',
            {
              tabindex: 1,
              target: '_blank',
              href: event.location.directionsUrl,
            },
            m('span.sya-icon.sya-icon--location'),
            m('span', Util.translate('event.directions'))
          ) : null
        ),
        m('.sya-event__description', event.description),
      ]
    }
  }
}
