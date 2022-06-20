/* exported RegistrationConfirm */
/* global m, Util */

function RegistrationConfirm() {
  return {
    view: function(vnode) {
      const event = vnode.attrs

      return m('.registration__confirmation', 
        m('.registration__confirmation__circle', 
          m('.registration__confirmation__title', Util.translate('registration.confirmation.title')),
          m('.registration__confirmation__subtitle', Util.translate('registration.confirmation.subtitle'))
        ),
        m('.registration__confirmation__actions', 
          m(m.route.Link,
            {
              href: m.route.get(), // TODO: Close registration confirmation
              class: 'registration__confirmation__back',
            },
            m('span.icon.icon--addon'),
            m('span', Util.translate('registration.confirmation.dismiss'))
          ),
          m(m.route.Link,
            {
              href: m.route.get() + '?share=1',
              class: 'registration__confirmation__share',
            },
            m('span.icon.icon--share'),
            m('span', Util.translate('registration.confirmation.invite'))
          ),
        ),
      )
    }
  }
}