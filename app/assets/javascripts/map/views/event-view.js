/* exported EventView */

/* global m, EventInfo, ImageCarousel, Registration, NavigationButton, App */

function EventView() {
  let event = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      App.data.getEvent(id).then(response => {
        event = response
        m.redraw()
      })
    },
    view: function() {
      if (!event) return null //m('div', "Event not found")

      return [
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: '/:layer',
          params: { layer: event.layer },
        }),
        m(NavigationButton, {
          float: 'right',
          icon: 'share',
          href: `/:layer/:id?share=1`,
          params: { id: event.id, layer: event.layer },
        }),
        m(EventInfo, event),
        event.images.length > 0 ? m(ImageCarousel, { images: event.images }) : null,
        m(Registration, event),
      ]
    }
  }
}