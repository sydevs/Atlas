/* globals Application */
/* exported PrivacyPanel */

class PrivacyPanel {

  constructor(element) {
    this.container = element
    this.linkInput = element.querySelector('.js-link')
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
  }

  show() {
    this.container.classList.add('panel--active')
  }

  hide() {
    this.container.classList.remove('panel--active')
  }

}
