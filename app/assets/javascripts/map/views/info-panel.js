/* global Application, Util, luxon */
/* exported InfoPanel */

class InfoPanel {

  constructor(element) {
    this.container = element
    this.timingDescription = document.getElementById('js-timing-description')
    this.languageBlock = document.getElementById('js-info-language')
    this.form = document.getElementById('js-registration')
    this.formFeedback = document.getElementById('js-registration-feedback')
    this.actions = document.getElementById('js-registration-actions')
    this.submitButton = document.getElementById('js-registration-submit')
    this.submitButton.addEventListener('click', event => { this.submit(); event.preventDefault() })

    this.formInputs = []
    const formInputNames = ['name', 'email', 'message', 'timeZone']
    formInputNames.forEach(name => {
      const formInput = this.form.querySelector(`[name=${name}]`)
      if (formInput) {
        this.formInputs.push(formInput)
      }
    })

    document.getElementById('js-info-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-info-close').addEventListener('click', () => Application.back())
    document.getElementById('js-registration-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-registration-close').addEventListener('click', () => this.hideMessages())

    this.elements = {}
    const attributes = ['name', 'address', 'day', 'description', 'online', 'time', 'timeZone', 'directions', 'phone', 'phoneName', 'phoneNumber', 'language']
    attributes.forEach(attribute => {
      this.elements[attribute] = this.container.querySelector(`[data-attribute="${attribute}"]`)
    })
  }

  show(event, venue = null) {
    this.event = event
    this.container.scrollTop = 0

    this.elements.name.textContent = event.label
    this.elements.address.textContent = event.address
    this.elements.description.innerHTML = Util.simpleFormat(event.description || '')
    this.elements.online.style = event.online ? '' : 'display: none'
    this.elements.day.textContent = Util.parseEventTiming(event, 'recurrence')
    this.elements.time.textContent = Util.parseEventTiming(event, 'duration')

    const localTimeZone = luxon.DateTime.local().zoneName
    if (event.online || localTimeZone != event.timing.timeZone) {
      this.elements.timeZone.textContent = Util.parseEventTiming(event, 'shortTimeZone')
      this.elements.timeZone.dataset.title = Util.parseEventTiming(event, 'longTimeZone')
    } else {
      this.elements.timeZone.textContent = ''
      this.elements.timeZone.dataset.title = ''
    }

    const registrationEnabled = !(event.registrationEndTime && Date.parse(event.registrationEndTime) < Date.now())
    this.container.classList.toggle('info--registration', registrationEnabled)

    this.elements.directions.style = venue ? '' : 'display: none'
    this.elements.directions.href = venue ? venue.directionsUrl : null

    this.elements.phone.style = event.phoneNumber ? '' : 'display: none'
    this.elements.phone.href = `tel:${event.phoneNumber}`
    this.elements.phoneNumber.innerText = event.phoneNumber
    this.elements.phoneName.style = event.phoneName ? '' : 'display: none'
    this.elements.phoneName.innerText = event.phoneName

    this.languageBlock.style = (Boolean(event.languageCode) && document.documentElement.lang.toUpperCase() != event.languageCode ? '' : 'display: none')
    this.elements.language.textContent = Util.translate(`languages.${event.languageCode}`).split(/[,;]/)[0]

    this.timingDescription.textContent = Util.parseEventCategoryDescription(event)

    Application.imageGallery.setImages(event.images)

    if (event.registrationMode in Util.translate('registration') && event.registrationUrl) {
      this.form.classList.add('registration--external')
      const linkElement = this.container.querySelector('[data-attribute="registration"]')
      linkElement.textContent = Util.translate(`registration.${event.registrationMode}`)
      linkElement.href = event.registrationUrl
    } else {
      this.form.classList.remove('registration--external')
      Application.timingCarousel.setTimings(event, event.timing.upcoming) // TODO: Is this correct? No other references to `upcoming` in codebase
    }
  }

  submit() {
    this.formFeedback.classList.remove('success')
    this.formFeedback.classList.remove('error')
    this.submitButton.setAttribute('disabled', 'disabled')

    let parameters = {}
    this.formInputs.forEach(input => {
      parameters[input.name] = input.value
    })

    parameters.eventId = this.event.id
    parameters.startingAt = new Date(this.form.querySelector('.js-timing.is-selected input[name=startingAt]').value)
    parameters.timeZone = luxon.DateTime.local().zoneName

    Application.atlas.createRegistration(parameters, response => {
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
