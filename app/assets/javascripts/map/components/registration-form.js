/* exported RegistrationForm */
/* global m, TimingCarousel, Util */

function RegistrationForm() {
  let alert = null // { type: 'error', message: "This is a test of the alert message." }
  let registered = true

  return {
    view: function(vnode) {
      const event = vnode.attrs

      return m('.registration__fields', 
        m(TimingCarousel, event),
        m('input.registration__input', {
          type: 'text',
          name: 'name',
          placeholder: "Name",
        }),
        m('input.registration__input', {
          type: 'text',
          name: 'email',
          placeholder: "Email",
        }),
        m('textarea.registration__textarea', {
          rows: 3,
          name: 'messsage',
          placeholder: "Message",
        }),
        alert ? m('.registration__message', { class: alert.type }, alert.message) : null,
        m('.registration__notice'),
        m('button.registration__submit', "Submit")
      )
    }
  }
}