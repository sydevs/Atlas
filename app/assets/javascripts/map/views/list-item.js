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
    element.addEventListener('click', () => this.open())

    const language = Object.keys(event.languages)[0] || ''
    if (document.documentElement.lang.toUpperCase() != language) {
      element.querySelector('[data-attribute="language"]').textContent = language
    } else {
      element.querySelector('[data-attribute="language"]').remove()
    }
  }

  open() {
    Application.setState({ event: this.event })
  }

  setHidden(hidden) {
    this.container.classList.toggle('item--hidden', hidden)
  }

}
