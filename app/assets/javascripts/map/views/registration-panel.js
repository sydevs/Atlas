/* global Application, Util */
/* exported RegistrationPanel */

class RegistrationPanel {

  constructor(element) {
    this.container = element
    this.form = element.querySelector('.js-form')
    this.formFeedback = element.querySelector('.js-form-feedback')
    this.submitButton = element.querySelector('.js-submit')
    this.submitButton.addEventListener('click', () => this.submit())
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
  }

  show(event) {
    this.event = event
    this.container.classList.add('panel--active')
    this.container.querySelector('[data-attribute="name"]').textContent = event.label
    this.container.querySelector('[data-attribute="description"]').innerHTML = Util.simpleFormat(event.description || event.category.description || '')
    this.container.querySelector('input[name="event_id"]').value = event.id
  }

  hide() {
    this.container.classList.remove('panel--active')
    Application.panels.listing.setActiveItem(null)
  }

  submit() {
    this.formFeedback.classList.remove('success')
    this.formFeedback.classList.remove('error')
    this.submitButton.setAttribute('disabled', 'disabled')

    Util.postForm('/map/registrations', this.form, event => {
      const response = JSON.parse(event.target.response)
      this.submitButton.removeAttribute('disabled')

      if (response.status == 'success') {
        this.formFeedback.classList.add('success')
      } else {
        this.formFeedback.classList.add('error')
      }

      this.formFeedback.innerText = response.message
    })
  }

}
