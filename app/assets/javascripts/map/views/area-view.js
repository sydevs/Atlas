/* exported AreaView */

/* global m, NavigationButton, App, Util */

function AreaView() {
  let area = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      App.data.getRecord(AtlasArea, id).then(response => {
        area = response
        const eventIds = (vnode.attrs.layer == AtlasEvent.LAYER.online ? area.onlineEventIds : area.offlineEventIds)
        App.data.getEvents(eventIds).then(events => {
          area.events = events
          m.redraw()
        })
      })
    },
    view: function(vnode) {
      if (!area) return null //m('div', "Area not found")

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: vnode.attrs.layer == AtlasEvent.LAYER.online ? '/:layer' : '/:layer/region/:id',
          params: { layer: vnode.attrs.layer, id: area.region.id }
        }),
        m('.panel__header', Util.translate('area.header', { area: area.label })),
        m(Navigation, {
          optional: true,
          items: Object.entries(AtlasEvent.LAYER).map(([key, layer]) => {
            const active = vnode.attrs.layer == layer
            const count = (key == 'online' ? area.onlineEventIds.length : area.offlineEventIds.length)
            return {
              label: Util.translate(`navigation.desktop.${key}`),
              active: active,
              badge: count,
              href: '/:layer/area/:id',
              params: { layer: layer, id: area.id },
            }
          })
        }),
        m('.list', area.events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'list__item', event: event })
        }))
      ]
    }
  }
}