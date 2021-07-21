/* global AtlasAPI, ListPanel, SearchPanel, InfoPanel, ImageGallery, TimingCarousel, SharingModal */
/* exported ListApplicationInstance */

class ListApplicationInstance {

  constructor() {
    this.container = document.getElementById('js-list-panel')
    this.listingType = document.body.dataset.list
    this.listPanel = new ListPanel(this.container)
    this.searchPanel = new SearchPanel(document.getElementById('js-search-panel'))
    this.infoPanel = new InfoPanel(document.getElementById('js-info-panel'))
    this.imageGallery = new ImageGallery(document.getElementById('js-image-gallery'))
    this.timingCarousel = new TimingCarousel(document.getElementById('js-timing-carousel'))
    this.share = new SharingModal(document.getElementById('js-share'))
    this.atlas = new AtlasAPI()
  }

  loadEvents() {
    const data = JSON.parse(this.container.dataset.events)
    this.showEvents(data)
  }

  showEvents(events) {
    this.listPanel.showEvents(events)
  }

  showOnlineEvents(events) {
    this.listPanel.showOnlineEvents(events)
  }

  showEvent(event) {
    this._setMode('event')
    this.infoPanel.show(event, event.venue)
    this.infoPanel.hideMessages()
  }

  back() {
    this._setMode('list')
  }

  _setListingType(type) {
    if (this.listingType == type) return

    this.listingType = type
    document.body.dataset.list = type
  }

  _setMode(mode) {
    if (this.mode == mode) return

    if (this.mode) {
      document.body.classList.remove(`mode--${this.mode}`)
    }

    this.mode = mode

    if (this.mode) {
      document.body.classList.add(`mode--${this.mode}`)
      document.body.scrollTop = 0
    }
  }
}
