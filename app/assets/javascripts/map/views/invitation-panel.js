/* global Application, Util, AtlasAPI */
/* exported InvitationPanel */

class InvitationPanel {

  constructor(element) {
    this.container = element
    this.form = element.querySelector('.js-form')
    this.formFeedback = element.querySelector('.js-form-feedback')
    this.submitButton = element.querySelector('.js-submit')
    this.submitButton.addEventListener('click', () => this.submit())
    element.querySelector('.js-privacy').addEventListener('click', () => Application.showPanel('privacy', this.event))
    element.querySelector('.js-panel-info').addEventListener('click', () => Application.showPanel('information', this.event))
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
  }

  show(event) {
    this.event = event
    const upcoming_date = new Date(event.upcoming_dates[0])
    let weekday = upcoming_date.toLocaleDateString(undefined, { weekday: 'long' })
    weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1)
    let month = upcoming_date.toLocaleDateString(undefined, { month: 'short' })
    month = month.charAt(0).toUpperCase() + month.slice(1)

    this.container.classList.add('panel--active')
    this.container.querySelector('[data-attribute="name"]').textContent = event.label
    this.container.querySelector('[data-attribute="description"]').innerHTML = Util.simpleFormat(event.description || event.category.description || '')
    this.container.querySelector('[data-attribute="day"]').innerHTML = weekday
    this.container.querySelector('[data-attribute="month"]').innerHTML = `${month} ${upcoming_date.getDate()}, ${upcoming_date.getFullYear()}`
    this.container.querySelector('[data-attribute="time"]').innerHTML = event.formatted_start_end_time
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

    AtlasAPI.register(this.form, event => {
      const response = JSON.parse(event.target.response)
      this.submitButton.removeAttribute('disabled')
      this.formFeedback.innerText = response.message

      if (response.status == 'success') {
        this.formFeedback.classList.add('success')
        this.event.registered = true
        Application.showPanel('sharing', this.event)
      } else if (response.status == 'info') {
        this.formFeedback.classList.add('success')
      } else {
        this.formFeedback.classList.add('error')
      }
    })
  }

}
