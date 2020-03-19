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

  async show(event) {
    if (navigator && navigator.share) {
      await this._shareNative(event)
    } else {
      this._shareFallback(event)
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

  _shareNative(event) {
    const url = `${window.origin}${event.path}`

    return new Promise(async (resolve) => {
      await navigator.share({
        title: event.label,
        text: event.description,
        url: url,
      })
  
      resolve()
    })
  }

  _shareFallback(event) {
    const url = `${window.origin}${event.path}`
    this.event = event
    this.linkInput.value = url
    this.container.classList.add('noscroll')
    this.container.classList.add('share-wrapper--active')

    for (let i = 0; i < this.sharingButtons.length; i++) {
      const button = this.sharingButtons[i]
      let href = button.dataset.template
      href = href.replace('{url}', encodeURIComponent(url))
      href = href.replace('{title}', encodeURIComponent(event.label))
      href = href.replace('{text}', encodeURIComponent(event.description))
      href = href.replace('{provider}', encodeURIComponent(window.location.hostname))
      button.href = href
    }
  }

}
