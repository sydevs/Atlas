/* globals Application */
/* exported ListToggle */

class ListToggle {

  constructor(element) {
    this.container = element
    this.container.addEventListener('click', () => this.toggle())
  }

  toggle() {
    if (event.target.tagName == 'INPUT') return

    if (Application.listingType == 'online') {
      Application._setListingType('offline')
    }
    
    this.container.classList.toggle('list-toggle--closed')
    this.container.classList.toggle('list-toggle--open')
    Application.map.invalidateSize()
  }

}
