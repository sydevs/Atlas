/* exported Registration */
/* global m, RegistrationForm, RegistrationConfirm, Util */

function Registration() {
  let registered = false
  let registration = null

  return {
    view: function(vnode) {
      const event = vnode.attrs
      let registerable = Boolean(event.timing.nextDateTime)

      return m('form.sya-registration',
        m('#registration'),
        m('.sya-registration__header',
          m('.sya-registration__header__text',
            m('.sya-registration__header__title',
              Util.translate(`registration.${registerable ? 'header' : 'closed'}`)
            ),
            m('.sya-registration__header__subtitle', event.timing.description)
          )
        ),
        registerable ?
          (registration ?
            m(RegistrationConfirm, {
              event: event,
              registration: registration,
              ondismiss: () => { registration = null }
            }) :
            (event.registrationMode != 'native' ? m('.sya-registration__external',
              m('a.sya-registration__external__action', {
                href: event.registrationUrl,
                target: '_blank',
              }, Util.translate(`registration.button.${event.registrationMode}`))
            ) : m(RegistrationForm, {
              event: event,
              onsubmit: response => {
                registration = response.registration
                m.redraw()
              },
            }))) :
          null
      )
    }
  }
}