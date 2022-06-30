/* exported MapView */

/* global m, Search, Navigation, Util */

function MapView() {
  let onlineEventsCount = null
  let offlineEventsCount = null

  return {
    view: function(vnode) {
      let device = Util.isDevice('mobile') ? 'mobile' : 'desktop'

      App.data.getList('online').then(events => {
        onlineEventsCount = events.length
        m.redraw()
      })

      if (App.map) {
        App.map.getRenderedEventIds().then(eventIds => {
          offlineEventsCount = eventIds.length
        }, _error => {
          offlineEventsCount = null
        }).finally(() => m.redraw())
  
        App.map.addEventListener('movestart', () => {
          offlineEventsCount = null
          m.redraw()
        })
      }

      return [
        m(Search, { floating: true }),
        m(Navigation, {
          items: ['offline', 'online'].map((layer) => {
            const active = vnode.attrs.layer == layer
            return {
              label: Util.translate(`navigation.desktop.${layer}`),
              href: `/${layer}`,
              active: active,
              badge: active ? null : (layer == 'online' ? onlineEventsCount : offlineEventsCount),
            }
          })
        }),
      ]
    }
  }
}