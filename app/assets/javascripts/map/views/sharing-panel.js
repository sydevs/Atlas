/* globals Application */
/* exported SharingPanel */

class SharingPanel {

  constructor(element) {
    this.container = element
    element.querySelector('.js-panel-info').addEventListener('click', () => Application.showPanel('information', this.event))
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
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
