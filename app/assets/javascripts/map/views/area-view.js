/* exported AreaView */

/* global m, NavigationButton, App, Util */

function AreaView() {
  let area = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      App.data.getRecord(AtlasArea, id).then(response => {
        area = response
        App.data.getEvents(area.eventIds).then(events => {
          area.events = events
          m.redraw()
        })
      })
    },
    view: function() {
      if (!area) return null //m('div', "Area not found")

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: vnode.attrs.layer == AtlasEvent.LAYER.online ? '/:layer' : '/:layer/country/:id',
          params: { layer: vnode.attrs.layer, id: area.region.id }
        }),
        m('.panel__header', Util.translate('area.header', { area: area.label })),
        m('.list', area.events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'list__item', event: event })
        }))
      ]
    }
  }
}