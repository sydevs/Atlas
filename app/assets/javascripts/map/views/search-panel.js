/* globals Application */
/* exported SearchPanel */

class SearchPanel {

  constructor(element) {
    this.container = element
    this.onlineInput = element.querySelector('[name="online"]')
    this.recurrenceInput = element.querySelector('[name="recurrence"]')
    this.languageCodeInput = element.querySelector('[name="languageCode"]')

    this.recurrenceInput.addEventListener('change', () => this.onSearch())
    this.languageCodeInput.addEventListener('change', () => this.onSearch())
  }

  onSearch() {
    let online = null

    if (this.onlineInput.value == 'true') {
      online = true
    } else if (this.onlineInput.value == 'false') {
      online = false
    }

    Application.atlas.searchEvents({
      online: online,
      recurrence: this.recurrenceInput.value || null,
      languageCode: this.languageCodeInput.value || null
    }, events => {
      Application.showEvents(events)
    })
  }

}
