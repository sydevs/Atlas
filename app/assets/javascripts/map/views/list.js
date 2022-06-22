/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let events = null

  function updateEvents(layer) {
    if (layer == 'offline') {
      return App.map.getRenderedEventIds().then(eventIds => {
        return eventIds.length > 0 ? App.atlas.getEvents(eventIds) : []
      }).then(response => {
        events = response
      }).catch(() => {
        events = null
      })
    } else {
      return App.atlas.getOnlineList().then(response => {
        events = response
      })
    }
  }

  return {
    oncreate: function(vnode) {
      App.map.addEventListener('update', () => {
        updateEvents(vnode.attrs.layer).finally(() => m.redraw())
      })
    },
    view: function(vnode) {
      let layer = m.route.param('layer')
      let mobile = Util.isDevice('mobile')

      let list = null
      if (events && events.length > 0) {
        list = m(List, { events: events })
      } else if (vnode.attrs.layer == 'offline') {
        list = m(ListFallback)
      }
    
      return [
        m(Search),
        m(Navigation, {
          items: mobile ?
            [[Util.translate('navigation.mobile.back'), '/']] :
            ['offline', 'online'].map((l) => [Util.translate(`navigation.desktop.${l}`), `/${l}`, layer == l])
        }),
        list,
      ]
    }
  }
}