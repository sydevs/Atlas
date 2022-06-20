/* exported EventInfo */
/* global m, Util */

function EventInfo() {
  return {
    view: function(vnode) {
      const event = vnode.attrs
      let language = Util.translate(`languages.${event.languageCode.toUpperCase()}`).split(/[,;]/)[0]

      return [
        m('.event',
          m('.event__sidebar',
            m('.event__sidebar__language', [
              m('div', Util.translate('event.language')),
              m('.event__sidebar__language-text', language),
            ])
          ),
          m('.event__label', event.label),
          m('.event__subtitle',
            event.online ? m('span.event__subtitle__online',
              m('strong', Util.translate('event.online')),
              m('div', Util.translate('event.online_from'))
            ) : null,
            m('span.event__subtitle__address', event.address)
          ),
          m('.event__meta',
            m('.event__meta__day', Util.parseEventTiming(event, 'recurrence')),
            m('.event__meta__time', Util.parseEventTiming(event, 'duration')),
            !event.online ? m('abbr.event__meta__timezone', {
              'data-title': Util.parseEventTiming(event, 'longTimeZone'),
            }, Util.parseEventTiming(event, 'shortTimeZone')) : null,
          ),
          event.phoneNumber ? m('a.event__phone',
            m('span.event__phone__number', {
              'data-prefix': Util.translate('event.tel') + ': ',
            }, event.phoneNumber),
            m('span.event__phone__name', event.phoneName)
          ) : null
        ),
        m('.event__actions',
          m('a',
            {
              tabindex: 1,
              href: '#register',
            },
            m('span.icon.icon--signup'),
            m('span', Util.translate('event.register'))
          ),
          event.location.directionsUrl ? m('a',
            {
              tabindex: 1,
              href: event.location.directionsUrl,
            },
            m('span.icon.icon--location'),
            m('span', Util.translate('event.directions'))
          ) : null
        ),
        m('.event__description', event.description),
      ]
    }
  }
}
