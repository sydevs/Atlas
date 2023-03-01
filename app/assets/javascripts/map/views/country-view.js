/* exported CountryView */

/* global m, NavigationButton, App, Util */

function CountryView() {
  let country = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasCountry, id).then(response => {
        console.log('get record', response)
        country = response
        m.redraw()
      })
    },
    view: function(vnode) {
      if (!country) return m(Loader)

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/',
        }),
        m('.sya-panel__header', country.label),
        m(Navigation, {
          optional: true,
          items: Object.entries(AtlasEvent.LAYER).map(([key, layer]) => {
            const active = vnode.attrs.layer == layer
            const count = (key == 'online' ? country.onlineEventIds.length : country.offlineEventIds.length)
            return {
              label: Util.translate(`navigation.desktop.${key}`),
              active: active,
              badge: count,
              href: '/:layer/country/:id',
              params: { layer: layer, id: country.id },
            }
          })
        }),
        m('.sya-list', country.regions.map(function(region) {
          const count = vnode.attrs.layer == AtlasEvent.LAYER.offline ? region.offlineEventIds.length : region.onlineEventIds.length
          if (!count) return

          return m(SimpleCard, {
            class: 'sya-list__item',
            id: region.id,
            label: region.name,
            count: count,
            layer: vnode.attrs.layer,
            model: AtlasRegion.key,
          })
        }))
      ]
    }
  }
}