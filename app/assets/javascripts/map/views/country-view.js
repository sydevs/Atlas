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
        m('.sya-panel__header', [
          m(NavigationButton, {
            float: 'left',
            icon: 'left',
            href: '/',
          }),
          country.label,
        ]),
        m('.sya-list', country.regions.map(function(region) {
          const count = region.offlineEventIds.length + region.onlineEventIds.length
          if (!count) return

          return m(SimpleCard, {
            class: 'sya-list__item',
            id: region.id,
            label: region.name,
            count: count,
            layer: vnode.attrs.layer,
            model: AtlasRegion.KEY,
          })
        }))
      ]
    }
  }
}