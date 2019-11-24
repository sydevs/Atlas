/* globals Application */
/* exported SharingPanel */

class SharingPanel {

  constructor(element) {
    this.container = element
    this.linkInput = element.querySelector('.js-link')
    element.querySelector('.js-panel-info').addEventListener('click', () => Application.showPanel('information', this.event))
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
    element.querySelector('.js-copy-link').addEventListener('click', () => this.copyLink())
  }

  show(event) {
    this.event = event
    this.container.classList.add('panel--active')
    this.container.classList.toggle('sharing--confirmation', event.registered || false)
  }

  hide() {
    this.container.classList.remove('panel--active')
    Application.panels.listing.setActiveItem(null)
  }

  copyLink() {
    this.linkInput.select()
    document.execCommand('copy')
  }

}
