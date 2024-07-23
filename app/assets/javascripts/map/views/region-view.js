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
      console.log("REGION", region)

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/country/:id',
          params: { id: region.country.id }
        }),
        m('.sya-panel__header', region.label),
        m('.sya-list.list--compact', region.areas.map(function(area) {
          const count = area.offlineEventIds.length + area.onlineEventIds.length
          if (!count) return

          return m(SimpleCard, {
            class: 'sya-list__item',
            id: area.id,
            label: area.name,
            sublabel: area.subtitle,
            count: count,
            layer: vnode.attrs.layer,
            model: AtlasArea.KEY,
          })
        }))
      ]
    }
  }
}