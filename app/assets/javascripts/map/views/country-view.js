/* exported CountryView */

/* global m, NavigationButton, App, Util */

function CountryView() {
  let country = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      App.data.getRecord(AtlasCountry, id).then(response => {
        console.log('get record', response)
        country = response
        m.redraw()
      })
    },
    view: function(vnode) {
      if (!country) return null //m('div', "Place not found")

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/',
        }),
        m('.panel__header', country.label),
        m(Navigation, {
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
        m('.list', country.regions.map(function(region) {
          const count = vnode.attrs.layer == AtlasEvent.LAYER.offline ? region.offlineEventIds.length : region.onlineEventIds.length
          if (!count) return

          return m(SimpleCard, {
            key: region.id,
            class: 'list__item',
            id: region.id,
            label: region.label,
            count: count,
            layer: vnode.attrs.layer,
            model: AtlasRegion.key,
          })
        }))
      ]
    }
  }
}