/* global L, Data, Events, DateInput */
/* exported Sidebar */

const Sidebar = {
  container: null,

  panels: {
    list: null,
    details: null,
    register: null,
    result: null,
  },

  details: {
    title: null,
    subtitle: null,
    description: null,
    address: null,
    timing: null,
  },

  registration: {
    id: null,
    date: null,
  },

  result: {
    invite: null,
  },

  visible_panel_count: 0,

  load() {
    Sidebar.container = document.getElementById('sidebar')

    Sidebar.panels.list = document.getElementById('sidebar-list')
    Sidebar.panels.details = document.getElementById('sidebar-details')
    Sidebar.panels.register = document.getElementById('sidebar-register')
    Sidebar.panels.result = document.getElementById('sidebar-result')

    Sidebar.details.title = document.getElementById('details-title')
    Sidebar.details.subtitle = document.getElementById('details-subtitle')
    Sidebar.details.description = document.getElementById('details-description')
    Sidebar.details.address = document.getElementById('details-meta-address')
    Sidebar.details.timing = document.getElementById('details-meta-timing')

    Sidebar.registration.id = document.getElementById('register-id')

    Sidebar.result.invite = document.getElementById('result-invite')

    // Set up click handlers for selecting
    let elements = document.getElementsByClassName('panel')
    for (let i = 0; i < elements.length; i++) {
      //L.DomEvent.on(elements[i], 'click', Sidebar._onPanelClick)
      elements[i].addEventListener('click', Sidebar._onPanelClick)
    }

    //L.DomEvent.on(document.getElementById('register-form'), 'submit', Sidebar.submitRegistration)
    document.getElementById('register-form').addEventListener('submit', Sidebar.submitRegistration)
    Sidebar.result.invite.addEventListener('focus', function() { this.select() })
    Sidebar.setActive('list')
  },

  openPanel(panel_id, event_id) {
    let event = Data.events[event_id]

    switch (panel_id) {
    case 'details':
      Sidebar.details.title.innerText = event.name
      Sidebar.details.subtitle.innerText = event.category
      Sidebar.details.description.innerText = event.description
      Sidebar.details.address.innerText = event.venue.address.street
      Sidebar.details.timing.innerText = event.timing

      Sidebar.panels.details.dataset.id = event_id
      Events.setActive(event_id)
      break
    case 'register':
      Sidebar.registration.id.value = event_id
      DateInput.setDates(event.upcoming_dates)
      Events.setActive(event_id)
      break
    case 'result':
      Sidebar.result.invite.value = event.url + '?invite'
      break
    }

    Sidebar.setActive(panel_id)
  },

  closePanel(panel_id) {
    let panel = Sidebar.panels[panel_id]
    let wrapper = panel.parentNode.previousSibling

    while (wrapper != null && !L.DomUtil.hasClass(wrapper, 'visible')) {
      wrapper = wrapper.previousSibling
    }

    Sidebar.setActive(wrapper != null ? wrapper.dataset.panel : null)
  },

  setActive(active_id) {
    let visible_panel_count = 0

    let before_active = (active_id != null)
    for (let panel_id in Sidebar.panels) {
      if (panel_id == active_id) {
        L.DomUtil.removeClass(Sidebar.panels[panel_id].parentNode, 'disabled')
        L.DomUtil.addClass(Sidebar.panels[panel_id].parentNode, 'visible')
        visible_panel_count++
        before_active = false
      } else if (before_active) {
        if (L.DomUtil.hasClass(Sidebar.panels[panel_id].parentNode, 'visible')) {
          visible_panel_count++
          L.DomUtil.addClass(Sidebar.panels[panel_id].parentNode, 'disabled')
        }
      } else {
        L.DomUtil.removeClass(Sidebar.panels[panel_id].parentNode, 'disabled')
        L.DomUtil.removeClass(Sidebar.panels[panel_id].parentNode, 'visible')

        if (panel_id == 'details') {
          Events.setActive(null)
        }
      }
    }

    L.DomUtil.addClass(Sidebar.container, `width-${visible_panel_count}`)
    L.DomUtil.removeClass(Sidebar.container, `width-${Sidebar.visible_panel_count}`)
    Sidebar.visible_panel_count = visible_panel_count
  },

  submitRegistration(event) {
    if (typeof event !== 'undefined') event.preventDefault()
    Sidebar.openPanel('result', Sidebar.registration.id.value)
  },

  _onPanelClick(event) {
    let panel_id = this.parentNode.dataset.panel

    if (L.DomUtil.hasClass(Sidebar.panels[panel_id].parentNode, 'disabled')) {
      Sidebar.setActive(panel_id)
    } else if (event.target.className == 'panel-close') {
      Sidebar.closePanel(this.parentNode.dataset.panel)
    } else if (event.target.className == 'event-register') {
      const event_id = event.target.parentNode.parentNode.dataset.id
      Sidebar.openPanel('register', event_id)
    } else if (event.target.className == 'event-expand') {
      let event_element = event.target.parentNode.parentNode
      Events.toggleDetails(event_element)
      event.target.innerText = (L.DomUtil.hasClass(event_element, 'expand') ? 'less info' : 'more info')
    //} else if (event.target.className.lastIndexOf('event-', 0) === 0) {
    //  event_id = event.target.parentNode.parentNode.dataset.id
    //  Sidebar.openPanel('details', event_id)
    } else if (event.target.id == 'details-register') {
      const event_id = event.target.parentNode.dataset.id
      Sidebar.openPanel('register', event_id)
    }
  },
}
