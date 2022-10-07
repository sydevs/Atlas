/* exported RegistrationConfirm */
/* global m, Util */

function RegistrationConfirm() {
  return {
    onbeforeremove: function(vnode) {
      vnode.dom.classList.add('fadeout')
      return new Promise(function(resolve) {
        vnode.dom.addEventListener('animationend', resolve)
      })
    },
    oninit: function(vnode) {
      const event = vnode.attrs.event
      const registration = vnode.attrs.registration
      const startDate = luxon.DateTime.fromISO(registration.startingDate)

      console.log(
        'atlas_registration',
        {
          email: registration.email,
          FIRSTNAME: registration.firstName,
          LASTNAME: registration.lastName,
          TIMEZONE: registration.timeZone,
        },
        {
          id: registration.id,
          data: {
            url: event.url,
            label: event.label,
            description: event.description,
            address: event.address,
            onlineUrl: event.onlineUrl,
            timing: event.timing.timeString,
            date: registration.startingDate,
            weekday: startDate.toLocaleString({ weekday: 'long' }).toUpperCase(),
          }
        }
      )

      sendinblue.track(
        'atlas_registration',
        {
          email: registration.email,
          FIRSTNAME: registration.firstName,
          LASTNAME: registration.lastName,
          TIMEZONE: registration.timeZone,
        },
        {
          id: registration.id,
          data: {
            url: event.url,
            label: event.label,
            address: event.address,
            timing: event.timing.timeString,
            date: registration.startingDate,
            weekday: registration.startingDate.toLocaleString({ weekday: 'long' }).toUpperCase(),
          }
        }
      )
    },
    view: function(vnode) {
      const event = vnode.attrs.event

      return m('.sya-registration__confirmation', 
        m('.sya-registration__confirmation__circle', 
          m('.sya-registration__confirmation__title', Util.translate('registration.confirmation.title')),
          m('.sya-registration__confirmation__subtitle', Util.translate('registration.confirmation.subtitle'))
        ),
        m('.sya-registration__confirmation__actions', 
          m(m.route.Link,
            {
              href: m.route.get(), // TODO: Close registration confirmation
              class: 'sya-registration__confirmation__back',
              onclick: () => vnode.attrs.ondismiss(),
            },
            m('span.sya-icon.sya-icon--addon'),
            m('span', Util.translate('registration.confirmation.dismiss'))
          ),
          m(m.route.Link,
            {
              href: m.route.get() + '?share=1',
              class: 'sya-registration__confirmation__share',
            },
            m('span.sya-icon.sya-icon--share'),
            m('span', Util.translate('registration.confirmation.invite'))
          ),
        ),
      )
    }
  }
}