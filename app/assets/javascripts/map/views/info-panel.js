/* global Application, Util */
/* exported InfoPanel */

class InfoPanel {

  constructor(element) {
    this.container = element
    this.timingDescription = document.getElementById('js-timing-description')
    this.languageBlock = document.getElementById('js-info-language')
    this.form = document.getElementById('js-registration')
    this.formFeedback = document.getElementById('js-registration-feedback')
    this.submitButton = document.getElementById('js-registration-submit')
    this.submitButton.addEventListener('click', event => { this.submit(); event.preventDefault() })

    document.getElementById('js-info-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-info-close').addEventListener('click', () => Application.back())
    document.getElementById('js-registration-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-registration-close').addEventListener('click', () => this.hideMessages())
  }

  show(event, venue = null) {
    this.event = event
    this.container.scrollTop = 0

    this.container.querySelector('[data-attribute="name"]').textContent = event.label
    this.container.querySelector('[data-attribute="address"]').textContent = event.address
    this.container.querySelector('[data-attribute="day"]').textContent = Util.parseTiming(event.timing)
    this.container.querySelector('[data-attribute="time"]').textContent = Util.parseTime(event.timing)
    this.container.querySelector('[data-attribute="description"]').innerHTML = Util.simpleFormat(event.description || '')
    this.container.querySelector('[data-attribute="online"]').style = event.online ? '' : 'display: none'

    this.form.classList.toggle('registration--confirmed', Boolean(event.registered))
    this.form.style = Date.parse(event.timing.registration_end_time) < Date.now() ? 'display: none' : ''

    const directions = this.container.querySelector('[data-attribute="directions"]')
    directions.style = venue ? '' : 'display: none'
    directions.href = venue ? venue.directions_url : null

    this.languageBlock.style = (Boolean(event.languageCode) && document.documentElement.lang.toUpperCase() != event.languageCode ? '' : 'display: none')
    this.container.querySelector('[data-attribute="language"]').textContent = Util.translate(`languages.${event.languageCode}`).split(/[,;]/)[0]

    this.timingDescription.textContent = Util.parseEventCategoryDescription(event)

    Application.imageGallery.setImages(event.images)

    if (event.registrationMode in Util.translate('registration') && event.registrationUrl) {
      this.form.classList.add('registration--external')
      const linkElement = this.container.querySelector('[data-attribute="registration"]')
      linkElement.textContent = Util.translate(`registration.${event.registrationMode}`)
      linkElement.href = event.registrationUrl
    } else {
      this.form.classList.remove('registration--external')
      Application.timingCarousel.setTimings(event, event.timing.upcoming)
      this.container.querySelector('input[name="event_id"]').value = event.id
    }
  }

  submit() {
    this.formFeedback.classList.remove('success')
    this.formFeedback.classList.remove('error')
    this.submitButton.setAttribute('disabled', 'disabled')

    Application.atlas.register(this.form, response => {
      this.submitButton.removeAttribute('disabled')
 
      if (response.status == 'success') {
        this.formFeedback.innerText = null
        this.event.registered = true
        this.form.classList.add('registration--confirmed')
        window.hash = '#confirmation'
      } else if (response.status == 'info') {
        this.formFeedback.innerText = response.message
        this.formFeedback.classList.add('success')
      } else {
        this.formFeedback.innerText = response.message
        this.formFeedback.classList.add('error')
      }
    })
  }

  hideMessages() {
    this.form.classList.remove('registration--confirmed')
    this.formFeedback.innerText = ''
    this.form.reset()
  }

}
