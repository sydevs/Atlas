/* exported RegistrationForm */
/* global m, TimingCarousel, Util */

function RegistrationForm() {
  let alert = null // { type: 'error', message: "This is a test of the alert message." }

  const regexForEmailValidation = RegExp(/^\w+([\.-]?\w+)@\w+([\.-]?\w+)(\.\w{2,3})+$/);
  let emailErrorMessage = null;
  
  let data = {
    eventId: null,
    name: null,
    email: null,
    questions: {},
    startingAt: null,
  }

  let validateEmail = () => emailErrorMessage = regexForEmailValidation.test(data.email) ? '' : Util.translate('registration.form.emailInvalidErrorMessage');
  
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
          // onchange: event => { data.email = event.currentTarget.value },
          oninput: e => {
            data.email = e.currentTarget.value;
            validateEmail()
          },
          placeholder: Util.translate('registration.form.email'),
        }),
        emailErrorMessage && m('div.sya-registration__message.error', emailErrorMessage ),
        Object.values(event.registrationQuestions).map(function(question) {
          return m(RegistrationQuestion, {
            question: question,
            onchange: event => { data.questions[question.slug] = event.currentTarget.value },
          })
        }),
        alert ? m('.sya-registration__message', { class: alert.status }, alert.message) : null,
        m('.sya-registration__notice',
          m.trust(Util.translate('registration.notice.text', {
            link: `<a class="sya-registration__notice-link" href="/${AtlasApp.config.locale}/privacy" target="_blank">${Util.translate('registration.notice.link')}</a>`
          }))
        ),
        m('button.sya-registration__submit', Util.translate('registration.form.submit'))
      )
    }
  }
}