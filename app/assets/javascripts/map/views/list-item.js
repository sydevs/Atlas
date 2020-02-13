/* globals Application */
/* exported ListItem */

class ListItem {

  constructor(element, event) {
    this.container = element
    this.event = event
    element.querySelector('[data-attribute="name"]').textContent = event.name || event.label
    element.querySelector('[data-attribute="address"]').textContent = event.address_text || ''
    element.querySelector('[data-attribute="distance"]').textContent = event.distance_text || ''
    element.querySelector('[data-attribute="distance"]').style = (event.distance_text ? '' : 'display: none')
    element.querySelector('[data-attribute="day"]').textContent = event.recurrence_in_words || ''
    element.querySelector('[data-attribute="time"]').textContent = event.formatted_start_end_time || ''
    element.querySelector('[data-attribute="language"]').textContent = Object.keys(event.languages)[0] || ''
    element.addEventListener('click', () => this.open())
  }

  open() {
    Application.showEvent(this.event)
  }

  setActive(active) {
    this.container.classList.toggle('item--active', active)
  }

  setHidden(hidden) {
    this.container.classList.toggle('item--hidden', hidden)
  }

}
