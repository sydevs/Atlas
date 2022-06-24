/* exported MapView */

/* global m, Search, Navigation, Util */

function MapView() {
  let onlineEventsCount = null

  return {
    view: function(vnode) {
      let device = Util.isDevice('mobile') ? 'mobile' : 'desktop'

      App.data.getList('online').then(events => { onlineEventsCount = events.length })

      return [
        m(Search, { floating: true }),
        m(Navigation, {
          items: ['offline', 'online'].map((layer) => {
            const active = vnode.attrs.layer == layer
            return {
              label: Util.translate(`navigation.desktop.${layer}`),
              href: `/${layer}`,
              active: active,
              badge: (layer == 'online' && !active) ? onlineEventsCount : null,
            }
          })
        }),
      ]
    }
  }
}