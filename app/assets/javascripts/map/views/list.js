/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let events = []

  return {
    oncreate: function() {
      /*App.atlas.getEvents({
        online: m.route.param('layer') == 'online',
      }).then(response => {
        events = response
        m.redraw()
      })*/
    },
    view: function() {
      let layer = m.route.param('layer')
      let mobile = Util.isDevice('mobile')
    
      return [
        m(Search),
        m(Navigation, {
          items: mobile ?
            [[Util.translate('navigation.mobile.back'), '/map']] :
            ['offline', 'online'].map((l) => [Util.translate(`navigation.desktop.${l}`), `/${l}`, layer == l])
        }),
        events.length > 0 ?
          m(List, { events: events }) :
          m(ListFallback),
      ]
    }
  }
}