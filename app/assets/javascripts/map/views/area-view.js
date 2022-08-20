/* exported AreaView */

/* global m, List, NavigationButton, App, Util */

function AreaView() {
  let area = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      App.data.getArea(id).then(response => {
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
          href: '/',
        }),
        m('.panel__header', Util.translate('area.header', { area: area.label })),
        m(List, { events: area.events }),
      ]
    }
  }
}