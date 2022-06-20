/* exported EventView */

/* global m, EventInfo, ImageCarousel, Registration, NavigationButton, App */

function EventView() {
  let event = null

  return {
    oncreate: function() {
      const id = m.route.param('id')
      App.atlas.getEvent(id).then(response => {
        event = response
        m.redraw()
      })
    },
    view: function() {
      if (!event) return null //m('div', "Event not found")

      return [
        m(NavigationButton, {
          float: 'left',
          url: `/list/${event.online ? 'online' : 'offline'}`,
          icon: 'left',
        }),
        m(NavigationButton, {
          float: 'right',
          url: `/event/${event.id}?share=1`,
          icon: 'share',
        }),
        m(EventInfo, event),
        event.images.length > 0 ? m(ImageCarousel, { images: event.images }) : null,
        m(Registration, event),
      ]
    }
  }
}