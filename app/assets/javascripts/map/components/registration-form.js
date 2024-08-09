/* exported RegistrationForm */
/* global m, TimingCarousel, Util */

function RegistrationForm() {
  let alert = null // { type: 'error', message: "This is a test of the alert message." }

  const regexForEmailValidation = RegExp(/^\w+([\.\+-]?\w+)@\w+([\.-]?\w+)(\.\w{2,3})+$/);

  let data = {
    eventId: null,
    name: null,
    email: null,
    questions: {},
    startingAt: null,
    subscribe: true,
  }

  let validateEmail = () => regexForEmailValidation.test(data.email) ? alert = null : alert = { status: 'invalid', message: Util.translate('registration.form.email_invalid'), field: 'email'};
  
  return {
    view: function(vnode) {
      const event = vnode.attrs.event
      data.eventId = event.id

      return m('form.sya-registration__fields',
        {
          onsubmit: event => {
            event.preventDefault()
            AtlasApp.data.createRegistration(data).then(response => {
              alert = null
              
              if (response.status == 'success') {
                alert = null
                vnode.attrs.onsubmit(response)

                if (window.fathom) {
                  fathom.trackGoal('1QZFA0P0', 0)
                  fathom.trackGoal('MWFMC9XW', 0)
                }
              } else {
                alert = {
                  status: response.status,
                  message: response.message,
                }
              }
              
              m.redraw()
            })
          },
        },
        m(TimingCarousel, {
          event: event,
          onselect: value => { data.startingAt = value.toISO().substring(0, 10) },
        }),
        m('input.sya-registration__input', {
          type: 'text',
          name: 'name',
          value: data.name,
          onchange: event => { data.name = event.currentTarget.value },
          placeholder: Util.translate('registration.form.name'),
        }),
        m('input.sya-registration__input', {
          type: 'text',
          name: 'email',
          value: data.email,
          className: alert?.field === 'email' && 'error_input',
          oninput: e => {
            data.email = e.currentTarget.value;
            validateEmail()
          },
          placeholder: Util.translate('registration.form.email'),
        }),
        Object.values(event.registrationQuestions).map(function(question) {
          return m(RegistrationQuestion, {
            question: question,
            onchange: event => { data.questions[question.slug] = event.currentTarget.value },
          })
        }),
        alert ? m('.sya-registration__message', { class: alert.status }, alert.message) : null,
        event.registrationSignup ?
          m('.sya-registration__signup',
            m('label', {},
              m('input.sya-registration__checkbox', {
                type: 'checkbox',
                name: 'signup',
                value: 1,
                checked: data.subscribe,
                onclick: event => { data.subscribe = event.currentTarget.checked },
              }),
              m('span', event.registrationSignup)
            )
          )
          : null,
        m('.sya-registration__notice',
          m.trust(Util.translate('registration.notice.text', {
            link: `<a class="sya-registration__notice-link" href="/${AtlasApp.config.locale}/privacy" target="_blank">${Util.translate('registration.notice.link')}</a>`
          }))
        ),
        m('button.sya-registration__submit',{
          disabled: alert?.status === 'invalid' || !data?.name || !data.email
        }, Util.translate('registration.form.submit'))
      )
    }
  }
}