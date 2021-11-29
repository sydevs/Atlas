/* globals Application */
/* exported ListToggle */

class ListToggle {

  constructor(element) {
    this.container = element
    this.container.addEventListener('click', () => this.toggle())
  }

  toggle() {
    if (event.target.tagName == 'INPUT') return

    this.container.classList.toggle('list-toggle--closed')
    this.container.classList.toggle('list-toggle--open')
    if (this.container.classList.contains('list-toggle--closed')) {
      Application._setListingType('offline')
    }

    Application.map.invalidateSize()
  }

}
