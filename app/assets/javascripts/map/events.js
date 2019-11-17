
const Events = {
  list: {
    empty: null,
    suggestions: null,
    events: null,
  },

  venue_filter: {
    message: null,
    name: null,
  },

  active: null,

  load() {
    console.log('loading events.js')
    Events.list.empty = document.getElementById('empty-list')
    Events.list.suggestions = document.getElementById('suggestion-list')
    Events.list.events = document.getElementById('event-list')

    Events.venue_filter.message = document.getElementById('venue-filter')
    Events.venue_filter.name = document.getElementById('venue-filter-name')
    document.getElementById('venue-filter-reset').addEventListener('click', Events._onResetFilterClick)
  },

  filterByVenue(venue_id) {
    let events = Events.list.events.children

    for (let i = 0; i < events.length; i++) {
      const event_element = events[i]
      const event_data = Data.events[event_element.dataset.id]

      if (venue_id == null || event_data.venue.id == venue_id) {
        L.DomUtil.removeClass(event_element, 'hidden')
      } else {
        L.DomUtil.addClass(event_element, 'hidden')
      }
    }

    if (venue_id != null) {
      Events.venue_filter.name.innerText = Data.venues[venue_id].name
      L.DomUtil.addClass(Events.venue_filter.message, 'show')
    } else {
      L.DomUtil.removeClass(Events.venue_filter.message, 'show')
    }
  },

  toggleDetails(event) {
    if (L.DomUtil.hasClass(event, 'expand')) {
      L.DomUtil.removeClass(event, 'expand')
      Sidebar.closePanel('details')
    } else {
      L.DomUtil.addClass(event, 'expand')
      Sidebar.openPanel('details', event.dataset.id)
    }
  },

  setActive(event_id) {
    if (Events.active != null) {
      L.DomUtil.removeClass(Events.active, 'active')
      //Event.toggleDetails(Events.active)
    }

    if (event_id != null) {
      Events.active = document.getElementById('event_' + event_id)
      L.DomUtil.addClass(Events.active, 'active')
    }
  },

  _onResetFilterClick() {
    Map.reset()
    Events.filterByVenue(null)
  },

}
