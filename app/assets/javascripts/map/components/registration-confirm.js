/* exported RegistrationConfirm */
/* global m, TimingCarousel */

function RegistrationConfirm() {
  return {
    view: function(vnode) {
      const event = vnode.attrs

      return m('.registration__confirmation', 
        m('.registration__confirmation__circle', 
          m('.registration__confirmation__title', "Thank you for registering"),
          m('.registration__confirmation__subtitle', "you will receive an email shortly")
        ),
        m('.registration__confirmation__actions', 
          m(m.route.Link,
            {
              href: m.route.get(), // TODO: Close registration confirmation
              class: 'registration__confirmation__back',
            },
            m('span.icon.icon--addon'),
            m('span', "Register someone else")
          ),
          m(m.route.Link,
            {
              href: m.route.get() + '?share=1',
              class: 'registration__confirmation__share',
            },
            m('span.icon.icon--share'),
            m('span', "Invite a friend along")
          ),
        ),
      )
    }
  }
}