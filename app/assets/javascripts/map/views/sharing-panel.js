/* globals Application */
/* exported SharingPanel */

class SharingPanel {

  constructor(element) {
    this.container = element
    this.linkInput = element.querySelector('.js-link')
    this.sharingButtons = element.querySelectorAll('.js-sharing-button')
    element.querySelector('.js-panel-close').addEventListener('click', () => Application.showPanel('listing'))
    element.querySelector('.js-copy-link').addEventListener('click', () => this.copyLink())

    if (navigator.share) {
      element.querySelector('.js-desktop-share').remove()
      element.querySelector('.js-mobile-share').addEventListener('click', () => this.triggerMobileShare())
    } else {
      element.querySelector('.js-mobile-share').remove()
    }
  }

  show(event) {
    this.event = event
    this.linkInput.value = event.map_url
    this.container.classList.add('panel--active')
    this.container.classList.toggle('sharing--confirmation', event.registered || false)

    for (let i = 0; i < this.sharingButtons.length; i++) {
      const button = this.sharingButtons[i]
      let href = button.dataset.template
      href = href.replace('{url}', encodeURIComponent(event.map_url))
      href = href.replace('{title}', encodeURIComponent(event.label))
      href = href.replace('{text}', encodeURIComponent(event.description))
      href = href.replace('{provider}', encodeURIComponent(window.location.hostname))
      button.href = href
    }
  }

  hide() {
    this.container.classList.remove('panel--active')
    Application.panels.listing.setActiveItem(null)
  }

  copyLink() {
    this.linkInput.select()
    document.execCommand('copy')
  }
  
  triggerMobileShare() {
    navigator.share({
      title: this.event.label,
      text: this.event.description,
      url: this.event.map_url,
    })
  }

}
