const Templates = {

  load() {
    console.log('loading templates.js')
    Templates.event = document.getElementById('eventTemplate')
  },

  resultContainerHtml(eventIndex, event) {
    const element = document.importNode(Templates.event.content, true)
    element.querySelector('.event-name').textContent = event.name || event.label
    element.querySelector('.event-address').textContent = event.address_text || ''
    element.querySelector('.time-details > .day').textContent = event.recurrence_in_words || ''
    element.querySelector('.time-details > .time').textContent = event.formatted_start_end_time || ''
    element.querySelector('.register-button').dataset.eventId = event.id
    element.querySelector('.more-info-link').dataset.eventId = event.id
    return element
  }
  
}