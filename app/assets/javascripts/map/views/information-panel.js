/* globals Application, Util */
/* exported InformationPanel */

class InformationPanel {

  constructor(element) {
    this.container = element
    element.querySelector('.js-panel-share').addEventListener('click', () => Application.showPanel('sharing', this.event))
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
    element.querySelector('.js-register').addEventListener('click', () => this.openRegistration())
  }

  show(event) {
    this.event = event
    this.container.classList.add('panel--active')

    let images = event.images.map(image => {
      return `<img src="${image.thumbnail_url}" />`
    }).join('')

    this.container.querySelector('[data-attribute="name"]').textContent = event.name || event.label
    this.container.querySelector('[data-attribute="description"]').innerHTML = Util.simpleFormat(event.description || event.category.description || '')
    this.container.querySelector('[data-attribute="images"]').innerHTML = images
  }

  hide() {
    this.container.classList.remove('panel--active')
    Application.panels.listing.setActiveItem(null)
  }

  openRegistration() {
    Application.showPanel('registration', this.event)
  }

}
