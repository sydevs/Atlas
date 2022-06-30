/* exported RegistrationForm */
/* global m, TimingCarousel, Util */

function RegistrationForm() {
  let alert = null // { type: 'error', message: "This is a test of the alert message." }
  let data = {
    eventId: null,
    name: 'Dave',
    email: 'test@test.com ',
    message: 'testing...',
    startingAt: null,
  }

  return {
    view: function(vnode) {
      const event = vnode.attrs.event
      data.eventId = event.id

      return m('form.registration__fields',
        {
          onsubmit: event => {
            event.preventDefault()
            App.data.createRegistration(data).then(response => {
              console.log('response', response)
              if (response.status == 'success') {
                alert = null
                vnode.attrs.onsubmit()
              } else {
                alert = response
              }
              
              m.redraw()
            })
          },
        },
        m(TimingCarousel, {
          event: event,
          onselect: value => { data.startingAt = value.toISO().substring(0, 10) },
        }),
        m('input.registration__input', {
          type: 'text',
          name: 'name',
          value: data.name,
          onchange: event => { data.name = event.currentTarget.value },
          placeholder: Util.translate('registration.form.name'),
        }),
        m('input.registration__input', {
          type: 'text',
          name: 'email',
          value: data.email,
          onchange: event => { data.email = event.currentTarget.value },
          placeholder: Util.translate('registration.form.email'),
        }),
        m('textarea.registration__textarea', {
          rows: 3,
          name: 'message',
          value: data.message,
          onchange: event => { data.message = event.currentTarget.value },
          placeholder: Util.translate('registration.form.message'),
        }),
        alert ? m('.registration__message', { class: alert.status }, alert.message) : null,
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