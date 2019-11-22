/* global AtlasAPI, WorldMap, SearchBox, ListingPanel, InformationPanel, RegistrationPanel, SharingPanel */
/* exported Applicatio */

class ApplicationInstance {

  constructor() {
    const map = document.getElementById('map')
    const initialLocation = JSON.parse(map.dataset.location)

    this.map = new WorldMap(map)
    this.activePanel = null
    this.panels = {}
    this.panels.listing = new ListingPanel(document.getElementById('js-listing-panel'))
    this.panels.information = new InformationPanel(document.getElementById('js-information-panel'))
    this.panels.registration = new RegistrationPanel(document.getElementById('js-registration-panel'))
    this.panels.sharing = new SharingPanel(document.getElementById('js-sharing-panel'))
    this.search = new SearchBox(document.getElementById('js-search'))
    this.atlas = new AtlasAPI()
    this.loadEvents(initialLocation)
  }

  toggleCollapsed() {
    document.body.classList.toggle('collapsed')
  }

  showPanel(panelKey, event = null) {
    if (this.activePanel) {
      this.activePanel.hide()
    }

    if (panelKey && event) {
      this.activePanel = this.panels[panelKey]
      this.activePanel.show(event)
      this.panels.listing.setActiveItem(event.id)
      this.map.zoomToVenue(event)
    } else {
      this.activePanel = null
    }
  }

  loadEvents(query) {
    this.showPanel(null)
    this.atlas.query(query, events => {
      this.map.addEventMarkers(events)
      this.map.zoomToEvents(events)
      this.panels.listing.setEvents(events)
    })
  }

}

document.addEventListener('DOMContentLoaded', () => {
  window.Application = new ApplicationInstance()
})
