/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let events = null

  function updateEvents() {
    App.map.getRenderedEventIds().then(eventIds => {
      if (eventIds == null || eventIds.length < 1) {
        events = eventIds
        m.redraw()
      } else {
        App.atlas.getEvents(eventIds).then(response => {
          events = response
          m.redraw()
        })
      }
    })
  }

  return {
    oncreate: function() {
      App.map.addEventListener('update', () => {
        updateEvents()
      })
    },
    view: function() {
      let layer = m.route.param('layer')
      let mobile = Util.isDevice('mobile')
    
      return [
        m(Search),
        m(Navigation, {
          items: mobile ?
            [[Util.translate('navigation.mobile.back'), '/']] :
            ['offline', 'online'].map((l) => [Util.translate(`navigation.desktop.${l}`), `/${l}`, layer == l])
        }),
        events == null ?
          null :
          (events.length > 0 ?
            m(List, { events: events }) :
            m(ListFallback)),
      ]
    }
  }
}