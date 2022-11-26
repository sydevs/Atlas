/* exported AreaView */

/* global m, NavigationButton, App, Util */

function AreaView() {
  let area = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasArea, id).then(response => {
        area = response
        const eventIds = area.getEventIds(vnode.attrs.layer)
        AtlasApp.data.getEvents(eventIds).then(events => {
          area.events = events
          m.redraw()
        })
      })
    },
    onupdate: function(vnode) {
      const eventIds = area.getEventIds(vnode.attrs.layer)
      AtlasApp.data.getEvents(eventIds).then(events => {
        area.events = events
        m.redraw()
      })
    },
    view: function(vnode) {
      if (!area) return m(Loader)

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: (AtlasApp.config.default_view == 'list' ? '/:layer/region/:id' : '/:layer'),
          params: { layer: vnode.attrs.layer, id: area.region.id }
        }),
        m('.sya-panel__header', Util.translate('area.header', { area: area.label })),
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
        m('.sya-list', area.events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'sya-list__item', event: event })
        }))
      ]
    }
  }
}