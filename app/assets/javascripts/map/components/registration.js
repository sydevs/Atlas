/* exported Registration */
/* global m, RegistrationForm, RegistrationConfirm, Util */

function Registration() {
  return {
    view: function(vnode) {
      const event = vnode.attrs
      let registered = false
      let registerable = true

      return m('form.registration',
        m('#registration'),
        m('.registration__header',
          m('.registration__header__text',
            m('.registration__header__title',
              Util.translate(registerable ? 'registration.header' : 'registration.closed')
            ),
            m('.registration__header__subtitle', event.timing.description)
          )
        ),
        registerable ?
          (registered ?
            m(RegistrationConfirm, event) :
            (event.registrationMode != 'native' ? m('registration__external',
              m('a.registration__external__action', {
                target: '_blank',
              }, Util.translate(`registration.button.${event.registrationMode}`))
            ) : m(RegistrationForm, event))) :
          null
      )
    }
  }
}