/* globals */
/* exported SharingModal */

class SharingModal {

  constructor(element) {
    this.container = element
    this.linkInput = document.getElementById('js-share-link')
    this.sharingButtons = document.querySelectorAll('.js-share-button')
    document.getElementById('js-share-close').addEventListener('click', () => this.hide())
    document.getElementById('js-share-copy').addEventListener('click', () => this.copyLink())
    document.getElementById('js-share-link').addEventListener('focus', () => this.copyLink())
  }

  show(event) {
    if (navigator.share) {
      this.triggerMobileShare(event)
    } else {
      this.event = event
      this.linkInput.value = event.map_url
      this.container.classList.add('noscroll')
      this.container.classList.add('share-wrapper--active')

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
  }

  hide() {
    this.container.classList.remove('noscroll')
    this.container.classList.remove('share-wrapper--active')
  }

  copyLink() {
    this.linkInput.select()
    document.execCommand('copy')
  }
  
  triggerMobileShare(event) {
    navigator.share({
      title: event.label,
      text: event.description,
      url: event.map_url,
    })
  }

}
