/* global AtlasAPI, WorldMap, SearchBox, ListingPanel, InformationPanel, RegistrationPanel, SharingPanel */
/* exported Applicatio */

class ApplicationInstance {

  constructor() {
    const map = document.getElementById('map')
    const initialLocation = JSON.parse(map.dataset.location)

    this.map = new WorldMap(map)
    this.panels = {}
    this.panels.listing = new ListingPanel(document.getElementById('js-listing-panel'))
    this.panels.information = new InformationPanel(document.getElementById('js-information-panel'))
    this.panels.registration = new RegistrationPanel(document.getElementById('js-registration-panel'))
    this.panels.sharing = new SharingPanel(document.getElementById('js-sharing-panel'))
    this.search = new SearchBox(document.getElementById('js-search'))
    this.atlas = new AtlasAPI()
    this.activePanel = this.panels.listing
    this.loadEvents(initialLocation)
    
    const collapseButtons = document.querySelectorAll('.js-collapse')
    for (let i = 0; i < collapseButtons.length; i++) {
      collapseButtons[i].addEventListener('click', () => this.toggleCollapsed())
    }
  }

  toggleCollapsed(collapsed) {
    document.body.classList.toggle('collapsed', collapsed)
    this.map.leaflet.invalidateSize()
  }

  showPanel(panelKey, event = null) {
    if (this.activePanel) {
      this.activePanel.hide()
    }

    if (panelKey) {
      this.activePanel = this.panels[panelKey]

      if (event) {
        this.activePanel.show(event)
        this.panels.listing.setActiveItem(event.id)
        this.map.zoomToVenue(event)
      } else {
        this.activePanel.show(event)
      }
    } else {
      this.activePanel = null
    }
  }

  loadEvents(query) {
    this.showPanel('listing')
    this.atlas.query(query, events => {
      this.map.addEventMarkers(events)
      this.map.zoomToEvents(events)
      this.panels.listing.setEvents(events)
      this.toggleCollapsed(false)
    })
  }

}

document.addEventListener('DOMContentLoaded', () => {
  window.Application = new ApplicationInstance()
})
