/* global Application, Util */
/* exported InfoPanel */

class InfoPanel {

  constructor(element) {
    this.container = element
    this.timingDescription = document.getElementById('js-timing-description')
    this.languagesBlock = document.getElementById('js-info-languages')
    this.form = document.getElementById('js-registration')
    this.formFeedback = document.getElementById('js-registration-feedback')
    this.submitButton = document.getElementById('js-registration-submit')
    this.submitButton.addEventListener('click', event => { this.submit(); event.preventDefault() })
    document.getElementById('js-info-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-info-close').addEventListener('click', () => history.back())
    document.getElementById('js-registration-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-registration-close').addEventListener('click', () => this.hideConfirmation())
  }

  show(event) {
    this.event = event
    this.container.querySelector('[data-attribute="name"]').textContent = event.label
    this.container.querySelector('[data-attribute="address"]').textContent = event.address_text || ''
    this.container.querySelector('[data-attribute="directions"]').href = `http://www.google.com/maps/place/${event.latitude},${event.longitude}`
    this.container.querySelector('[data-attribute="day"]').textContent = event.recurrence_in_words
    this.container.querySelector('[data-attribute="time"]').textContent = event.formatted_start_end_time
    this.container.querySelector('[data-attribute="description"]').innerHTML = Util.simpleFormat(event.description || event.category.description || '')
    this.form.classList.toggle('registration--confirmed', Boolean(event.registered))

    const languageKey = Object.keys(event.languages)[0] || ''
    const language = Object.values(event.languages)[0]
    this.languagesBlock.style = (document.documentElement.lang.toUpperCase() == languageKey ? 'display: none' : '')
    this.container.querySelector('[data-attribute="languages"]').textContent = language

    this.timingDescription.textContent = event.timing.description

    Application.imageGallery.setImages(event.images)

    if (event.registration.mode != 'native' && event.registration.url) {
      this.form.classList.add('registration--external')
      const linkElement = this.container.querySelector('[data-attribute="registration"]')
      linkElement.textContent = event.registration.label
      linkElement.href = event.registration.url
    } else {
      this.form.classList.remove('registration--external')
      Application.timingCarousel.setTimings(event, event.upcoming_dates)
      this.container.querySelector('input[name="event_id"]').value = event.id
    }
  }

  submit() {
    this.formFeedback.classList.remove('success')
    this.formFeedback.classList.remove('error')
    this.submitButton.setAttribute('disabled', 'disabled')

    Application.atlas.register(this.form, event => {
      const response = JSON.parse(event.target.response)
      this.submitButton.removeAttribute('disabled')
 
      if (response.status == 'success') {
        this.formFeedback.innerText = null
        this.event.registered = true
        this.form.classList.add('registration--confirmed')
      } else if (response.status == 'info') {
        this.formFeedback.innerText = response.message
        this.formFeedback.classList.add('success')
      } else {
        this.formFeedback.innerText = response.message
        this.formFeedback.classList.add('error')
      }
    })
  }

  hideConfirmation() {
    this.form.classList.remove('registration--confirmed')
    this.form.reset()
  }

}
