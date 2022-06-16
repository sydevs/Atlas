/* exported Registration */
/* global m, RegistrationForm, RegistrationConfirm, Util */

function Registration() {
  return {
    view: function(vnode) {
      const event = vnode.attrs
      let registered = false

      return m('form.registration',
        m('#registration'),
        m('.registration__header',
          m('.registration__header__text',
            m('.registration__header__title', "Registration"),
            m('.registration__header__subtitle', Util.parseEventCategoryDescription(event))
          )
        ),
        registered ?
          m(RegistrationConfirm, event) :
          (event.registrationMode != 'native' ? m('registration__external',
            m('a.registration__external__action', {
              target: '_blank',
            }, "Register on Site")
          ) : m(RegistrationForm, event))
      )
    }
  }
}