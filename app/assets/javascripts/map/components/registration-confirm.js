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
    view: function(vnode) {
      const event = vnode.attrs.event

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
              onclick: () => vnode.attrs.ondismiss(),
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