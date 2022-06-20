/* exported RegistrationForm */
/* global m, TimingCarousel, Util */

function RegistrationForm() {
  let alert = null // { type: 'error', message: "This is a test of the alert message." }

  return {
    view: function(vnode) {
      const event = vnode.attrs

      return m('.registration__fields', 
        m(TimingCarousel, event),
        m('input.registration__input', {
          type: 'text',
          name: 'name',
          placeholder: Util.translate('registration.form.name'),
        }),
        m('input.registration__input', {
          type: 'text',
          name: 'email',
          placeholder: Util.translate('registration.form.email'),
        }),
        m('textarea.registration__textarea', {
          rows: 3,
          name: 'messsage',
          placeholder: Util.translate('registration.form.message'),
        }),
        alert ? m('.registration__message', { class: alert.type }, alert.message) : null,
        m('.registration__notice',
          m.trust(Util.translate('registration.notice.text', {
            link: `<a class="registration__notice-link" href="/${window.locale}/privacy" target="_blank">${Util.translate('registration.notice.link')}</a>`
          }))
        ),
        m('button.registration__submit', Util.translate('registration.form.submit'))
      )
    }
  }
}