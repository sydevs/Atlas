/* exported AreaView */

/* global m, NavigationButton, App, Util */

function AreaView() {
  let area = null

  return {
    oninit: function(vnode) {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasArea, id).then(response => {
        area = response
        const eventIds = area.offlineEventIds.concat(area.onlineEventIds)
        AtlasApp.data.getRecords(AtlasEvent, eventIds).then(events => {
          area.events = events
          m.redraw()
        })
      })
    },
    onupdate: function(vnode) {
      const eventIds = area.offlineEventIds.concat(area.onlineEventIds)
      AtlasApp.data.getRecords(AtlasEvent, eventIds).then(events => {
        area.events = events
        m.redraw()
      })
    },
    view: function(vnode) {
      if (!area) return m(Loader)
      console.log(area)

      return [
        m('.sya-panel__header', [
          m(NavigationButton, {
            float: 'left',
            icon: 'left',
            href: (AtlasApp.config.default_view == 'list' ? '/region/:id' : '/events'),
            params: { layer: vnode.attrs.layer, id: area.region.id }
          }),
          Util.translate('area.header', { area: area.label }),
        ]),
        m('.sya-list', area.events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'sya-list__item', event: event })
        }))
      ]
    }
  }
}