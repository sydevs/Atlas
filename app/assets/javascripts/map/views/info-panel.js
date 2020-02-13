/* global Application, Util */
/* exported InfoPanel */

class InfoPanel {

  constructor(element) {
    this.container = element
    this.form = document.getElementById('js-registration')
    this.formFeedback = document.getElementById('js-registration-feedback')
    this.submitButton = document.getElementById('js-registration-submit')
    this.submitButton.addEventListener('click', event => { this.submit(); event.preventDefault() })
    document.getElementById('js-info-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-info-close').addEventListener('click', () => Application.closeEvent())
    document.getElementById('js-registration-share').addEventListener('click', () => Application.share.show(this.event))
    document.getElementById('js-registration-close').addEventListener('click', () => this.hideConfirmation())
  }

  show(event) {
    this.event = event
    const upcoming_date = new Date(event.upcoming_dates[0])
    let weekday = upcoming_date.toLocaleDateString(undefined, { weekday: 'long' })
    weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1)

    this.container.querySelector('[data-attribute="name"]').textContent = event.label
    this.container.querySelector('[data-attribute="address"]').textContent = event.address_text || ''
    this.container.querySelector('[data-attribute="directions"]').href = `http://www.google.com/maps/place/${event.latitude},${event.longitude}`
    this.container.querySelector('[data-attribute="languages"]').textContent = Object.values(event.languages).join(', ')
    this.container.querySelector('[data-attribute="day"]').textContent = weekday
    this.container.querySelector('[data-attribute="time"]').textContent = event.formatted_start_end_time
    this.container.querySelector('[data-attribute="description"]').innerHTML = Util.simpleFormat(event.description || event.category.description || '')
    this.container.querySelector('input[name="event_id"]').value = event.id
    
    Application.imageGallery.setImages(event.images)
    Application.timingCarousel.setTimings(event, event.upcoming_dates)
  }

  submit() {
    this.formFeedback.classList.remove('success')
    this.formFeedback.classList.remove('error')
    this.submitButton.setAttribute('disabled', 'disabled')

    Application.atlas.register(this.form, event => {
      const response = JSON.parse(event.target.response)
      this.submitButton.removeAttribute('disabled')
      //this.formFeedback.innerText = response.message

      if (response.status == 'success') {
        //this.formFeedback.classList.add('success')
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
  }

}
