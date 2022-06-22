/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let events = null

  function updateEvents() {
    App.map.getRenderedEventIds().then(eventIds => {
      return eventIds.length > 0 ? App.atlas.getEvents(eventIds) : []
    }).then(response => {
      events = response
    }).catch(() => {
      events = null
    }).finally(() => {
      m.redraw()
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