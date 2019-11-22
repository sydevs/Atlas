/* globals Application */
/* exported SharingPanel */

class SharingPanel {

  constructor(element) {
    this.container = element
    element.querySelector('.panel__close').addEventListener('click', () => this.hide())
  }

  show(event) {
    this.event = event
    this.container.classList.add('panel--active')
  }

  hide() {
    this.container.classList.remove('panel--active')
    Application.panels.listing.setActiveItem(null)
  }

}
