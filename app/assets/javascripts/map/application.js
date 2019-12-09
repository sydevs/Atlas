/* global AtlasAPI, WorldMap, Hammer, Util,
          SearchBox, ListingPanel, InformationPanel, RegistrationPanel, SharingPanel, PrivacyPanel */
/* exported Applicatio */

class ApplicationInstance {

  constructor() {
    const map = document.getElementById('map')

    this.map = new WorldMap(map)
    this.panels = {}
    this.panels.listing = new ListingPanel(document.getElementById('js-listing-panel'))
    this.panels.information = new InformationPanel(document.getElementById('js-information-panel'))
    this.panels.registration = new RegistrationPanel(document.getElementById('js-registration-panel'))
    this.panels.sharing = new SharingPanel(document.getElementById('js-sharing-panel'))
    this.panels.privacy = new PrivacyPanel(document.getElementById('js-privacy-panel'))
    this.search = new SearchBox(document.getElementById('js-search'))
    this.atlas = new AtlasAPI(map.dataset.api)
    this.activePanel = { key: 'listing', event: null, panel: this.panels.listing }
    this.panelHistory = new Map()

    const initialEvents = JSON.parse(map.dataset.events).results
    if (initialEvents) {
      this.setEvents(initialEvents)

      if (map.dataset.featured == 'true') {
        this.showPanel('information', initialEvents[0])
      }
    }

    if (map.dataset.restricted == 'true') {
      this.map.lockBounds()
    }
    
    const collapseButtons = document.querySelectorAll('.js-collapse')
    for (let i = 0; i < collapseButtons.length; i++) {
      collapseButtons[i].addEventListener('click', () => this.toggleCollapsed())
    }
    
    const backButtons = document.querySelectorAll('.js-back')
    for (let i = 0; i < backButtons.length; i++) {
      backButtons[i].addEventListener('click', () => this.showPreviousPanel())
    }

    this.hammertime = new Hammer(document.getElementById('js-panels'))
    this.hammertime.get('tap').set({ enable: false })
    this.hammertime.get('doubletap').set({ enable: false })
    this.hammertime.get('press').set({ enable: false })
    this.hammertime.get('pan').set({ enable: false })
    this.hammertime.get('swipe').set({
      direction: Hammer.DIRECTION_VERTICAL,
      threshold: 5,
      velocity: 0.15,
    })

    this.hammertime.on('swipedown', _event => { if (Util.isMobile()) this.toggleCollapsed(true) })
    this.hammertime.on('swipeup', _event => { if (Util.isMobile()) this.toggleCollapsed(false) })
  }

  toggleCollapsed(collapsed) {
    const isCollapsed = document.body.classList.toggle('collapsed', collapsed)

    if (!isCollapsed) {
      this.search.setActive(false)
    }

    this.map.invalidatePanels()
  }

  showPanel(panelKey, event = null) {
    this.search.setActive(false)

    if (this.activePanel) {
      this.pushPanelHistory(this.activePanel)
      this.activePanel.panel.hide()
    }

    if (panelKey) {
      this.activePanel = {
        key: panelKey,
        event: event,
        panel: this.panels[panelKey],
      }

      if (panelKey == 'listing') {
        this.panelHistory.clear()
      } else {
        this.panelHistory.delete(panelKey)
      }

      if (event) {
        this.activePanel.panel.show(event)
        this.panels.listing.setActiveItem(event ? event.id : null)
        this.map.invalidateViewportDimensions()
        this.map.zoomToVenue(event)
      } else {
        this.map.invalidateViewportDimensions()
        this.map.fitToMarkers()
        this.activePanel.panel.show(event)
      }
    } else {
      this.map.invalidateViewportDimensions()
      this.map.fitToMarkers()
      this.activePanel = null
    }
  }

  showPreviousPanel() {
    if (this.activePanel) {
      this.activePanel.panel.hide()
      this.activePanel = this.popPanelHistory()
    }

    if (this.activePanel) {
      const event = this.activePanel.event
      if (event) {
        this.activePanel.panel.show(event)
        this.panels.listing.setActiveItem(event.id)
        this.map.zoomToVenue(event)
      } else {
        this.activePanel.panel.show()
        this.map.fitToMarkers()
      }
    }
  }

  pushPanelHistory(panelData) {
    this.panelHistory.delete(panelData.key)
    this.panelHistory.set(panelData.key, panelData)
  }

  popPanelHistory() {
    if (this.panelHistory.size > 0) {
      let entry = null
      for (entry of this.panelHistory);
      this.panelHistory.delete(entry[0])
      return entry[1]
    } else {
      return null
    }
  }

  loadEvents(query) {
    this.showPanel('listing')

    this.atlas.query(query, response => {
      if (response.status == 'success') {
        this.setEvents(response.results)
      } else {
        this.panels.listing.showEmptyResults(response.alternatives[0])
        this.map.zoomTo(query.latitude, query.longitude)
        this.toggleCollapsed(false)
        this.map.setEventMarkers([])
      }
    })
  }
  
  setEvents(events) {
    this.search.setActive(false)
    this.panels.listing.setEvents(events)

    if (!Util.isMobile()) {
      this.toggleCollapsed(false)
    }

    this.map.setEventMarkers(events)
  }

}

document.addEventListener('DOMContentLoaded', () => {
  window.Application = new ApplicationInstance()
})
