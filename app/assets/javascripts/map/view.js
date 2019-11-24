/* globals */
/* exported View */

const View = {

  load() {
    console.log('loading templates.js') // eslint-disable-line no-console
    View.event = document.getElementById('js-item-template')
  },

  appendEvent(event, container) {
    let element = document.importNode(View.item.content, true)
    View.displayEvent(event, element)
    container.appendChild(element)
  },

  displayEvent(event, element) {
    element.dataset.id = event.id
    element.querySelector('[data-attribute="name"]').textContent = event.name || event.label
    element.querySelector('[data-attribute="name"]').textContent = event.address_text || ''
    element.querySelector('[data-attribute="day"]').textContent = event.recurrence_in_words || ''
    element.querySelector('[data-attribute="time"]').textContent = event.formatted_start_end_time || ''
  },

}