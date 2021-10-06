/* globals Application */
/* exported ListToggle */

class ListToggle {

  constructor(element) {
    this.container = element
    this.container.addEventListener('click', () => this.toggle())

    this.onlineToggle = this.container.querySelector('input[value="online"]')
  }

  toggle() {
    if (event.target.tagName == 'INPUT') return

    if (this.onlineToggle && this.onlineToggle.checked) {
      Application._setListingType('offline')
      this.onlineToggle.checked = false
    }
    
    this.container.classList.toggle('list-toggle--closed')
    this.container.classList.toggle('list-toggle--open')
    Application.map.invalidateSize()
  }

}
