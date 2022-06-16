/* exported EventView */

/* global m, EventInfo, ImageCarousel, Registration, NavigationButton, AtlasAPI */

function EventView() {
  const atlas = new AtlasAPI()
  let event = null

  const id = m.route.param('id')
  atlas.getEvent(id, response => {
    event = response
    m.redraw()
  })

  return {
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
          url: `/event/${id}?share=1`,
          icon: 'share',
        }),
        m(EventInfo, event),
        event.images.length > 0 ? m(ImageCarousel, { images: event.images }) : null,
        m(Registration, event),
      ]
    }
  }
}