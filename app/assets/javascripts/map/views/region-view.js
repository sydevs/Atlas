/* exported RegionView */

/* global m, NavigationButton, App, Util */

function RegionView() {
  let region = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasRegion, id).then(response => {
        region = response
        m.redraw()
      })
    },
    view: function(vnode) {
      if (!region) return m(Loader)

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/:layer/country/:id',
          params: { layer: vnode.attrs.layer, id: region.country.id }
        }),
        m('.sya-panel__header', region.label),
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
        m('.sya-list.list--compact', region.areas.map(function(area) {
          const count = vnode.attrs.layer == AtlasEvent.LAYER.offline ? area.offlineEventIds.length : area.onlineEventIds.length
          if (!count) return

          return m(SimpleCard, {
            class: 'sya-list__item',
            id: area.id,
            label: area.name,
            count: count,
            layer: vnode.attrs.layer,
            model: AtlasArea.key,
          })
        }))
      ]
    }
  }
}