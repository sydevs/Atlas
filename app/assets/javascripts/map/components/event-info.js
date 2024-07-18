/* exported EventInfo */
/* global m, Util */

function EventInfo() {
  return {
    view: function(vnode) {
      const event = vnode.attrs
      let language = Util.translate(`languages.${event.languageCode.toUpperCase()}`).split(/[,;]/)[0]

      if (event.category == 'inactive') {
        return m(InactiveEventInfo, event)
      }

      return [
        m('.sya-event',
          event.languageCode != AtlasApp.config.locale ? m('.sya-event__sidebar',
            m('.sya-event__sidebar__bubble', [
              m('div', Util.translate('event.language')),
              m('.sya-event__sidebar__bubble-highlight', language),
            ])
          ) : null,
          m('.sya-event__label', event.label),
          m('.sya-event__subtitle',
            event.online ?
              m('.sya-event__subtitle__online', Util.translate('event.online')) :
              null,
            m('.sya-event__subtitle__address', event.online ? Util.translate('event.online_from', { city: event.address }) : event.address)
          ),
          m('.sya-event__meta', m('.sya-event__meta__day', event.timing.dateString)),
          m('.sya-event__meta',
            m('.sya-event__meta__time', event.timing.timeString),
            event.online ?
              null :
              m('abbr.sya-card__meta__timezone', {
                'data-tooltip': event.timing.timeZone('long'),
              }, event.timing.timeZone('short'))
          ),
          event.contact.phoneNumber ? m('a.sya-contact__direct',
            { href: `tel:${event.contact.phoneNumber}` },
            m('span.sya-contact__direct__detail', {
              'data-prefix': Util.translate('event.contact.tel') + ': ',
            }, event.contact.phoneNumber),
            m('span.sya-contact__direct__name', event.contact.phoneName)
          ) : null,
          m('.sya-event__actions',
            m('a',
              {
                tabindex: 1,
                target: (event.registrationMode == 'native' ? '_self' : '_blank'),
                href: (event.registrationMode == 'native' ? '#registration' : event.registrationUrl),
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
        ),
        m('.sya-event__description', m.trust(event.descriptionHtml)),
      ]
    }
  }
}

function InactiveEventInfo() {
  return {
    view: function(vnode) {
      const event = vnode.attrs

      let web_links = ['meetup', 'facebook'].map(service => {
        return event.contact[service] ? m('a.sya-contact__link', {
          href: Util.withProtocol(event.contact[service]),
          target: '_blank',
        }, Util.translate(`event.contact.${service}`)) : null
      }).filter(Boolean)

      return [
        m('.sya-event',
          m('.sya-event__sidebar', 
            m('.sya-event__sidebar__bubble', [
              m('div', Util.translate('event.inactive.notice')),
            ])
          ),
          m('.sya-event__label', event.label),
          m('.sya-event__subtitle',
            m('.sya-event__subtitle__address', event.address)
          ),

          m('.sya-contact__title', Util.translate('event.contact.title')),
          event.contact.phoneNumber ? m('a.sya-contact__direct',
            { href: `tel:${event.contact.phoneNumber}` },
            m('span.sya-contact__direct__detail', {
              'data-prefix': Util.translate('event.contact.tel') + ': ',
            }, event.contact.phoneNumber),
            m('span.sya-contact__direct__name', event.contact.phoneName)
          ) : null,

          event.contact.emailAddress ? m('a.sya-contact__direct',
            { href: `mailto:${event.contact.emailAddress}` },
            m('span.sya-contact__direct__detail', {
              'data-prefix': Util.translate('event.contact.email') + ': ',
            }, event.contact.emailAddress),
            //m('span.sya-contact__direct__name', event.contact.phoneName)
          ) : null,

          web_links.length > 0 ? m('.sya-contact__links', web_links) : null,
        ),
        m('.sya-event__description', m.trust(event.descriptionHtml)),
      ]
    }
  }
}
