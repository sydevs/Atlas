/* exported RegionView */

/* global m, NavigationButton, App, Util */

function RegionView() {
  let region = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      App.data.getRecord(AtlasRegion, id).then(response => {
        region = response
        m.redraw()
      })
    },
    view: function(vnode) {
      if (!region) return null //m('div', "Region not found")

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/:layer/country/:id',
          params: { layer: vnode.attrs.layer, id: region.country.id }
        }),
        m('.panel__header', region.label),
        m(Navigation, {
          optional: true,
          items: Object.entries(AtlasEvent.LAYER).map(([key, layer]) => {
            const active = vnode.attrs.layer == layer
            const count = (key == 'online' ? region.onlineEventIds.length : region.offlineEventIds.length)
            return {
              label: Util.translate(`navigation.desktop.${key}`),
              active: active,
              badge: count,
              href: '/:layer/region/:id',
              params: { layer: layer, id: region.id },
            }
          })
        }),
        m('.list.list--compact', region.areas.map(function(area) {
          const count = vnode.attrs.layer == AtlasEvent.LAYER.offline ? area.offlineEventIds.length : area.onlineEventIds.length
          if (!count) return

          return m(SimpleCard, {
            class: 'list__item',
            id: area.id,
            label: area.label,
            count: count,
            layer: vnode.attrs.layer,
            model: AtlasArea.key,
          })
        }))
      ]
    }
  }
}