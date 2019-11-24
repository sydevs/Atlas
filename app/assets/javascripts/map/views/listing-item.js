/* globals Application */
/* exported ListingItem */

class ListingItem {

  constructor(element, event) {
    this.container = element
    this.event = event
    element.querySelector('[data-attribute="name"]').textContent = event.name || event.label
    element.querySelector('[data-attribute="address"]').textContent = event.address_text || ''
    element.querySelector('[data-attribute="day"]').textContent = event.recurrence_in_words || ''
    element.querySelector('[data-attribute="time"]').textContent = event.formatted_start_end_time || ''
    element.querySelector('.js-register').addEventListener('click', () => this.openRegistration())
    element.querySelector('.js-more').addEventListener('click', () => this.openInformation())
  }

  openRegistration() {
    Application.showPanel('registration', this.event)
  }

  openInformation() {
    Application.showPanel('information', this.event)
  }

  setActive(active) {
    this.container.classList.toggle('item--active', active)
  }

  setHidden(hidden) {
    this.container.classList.toggle('item--hidden', hidden)
  }

}
