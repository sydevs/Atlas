/* exported EventView */

/* global m, EventInfo, ImageCarousel, Registration, NavigationButton, App */

function EventView() {
  let event = null

  return {
    oninit: function() {
      const id = m.route.param('id')
      AtlasApp.data.getRecord(AtlasEvent, id).then(response => {
        event = response
        m.redraw()
      })
    },
    view: function() {
      if (!event) return null //m('div', "Event not found")

      let href = '/:layer/:model/:id'
      let params = { layer: event.layer }

      if (event.location.eventIds.length > 1) {
        params['model'] = event.location.type.toLowerCase()
        params['id'] = event.location.id
      } else if (window.sya.config.search) {
        href = '/:layer'
      } else {
        params['model'] = event.location.parentType.toLowerCase()
        params['id'] = event.location.parentId
      }

      return [
        //m(EventMetadata, { event: event }),
        m(NavigationButton, {
          float: 'left',
          icon: 'left',
          href: href,
          params: params,
        }),
        m(NavigationButton, {
          float: 'right',
          icon: 'share',
          href: `/:layer/event/:id?share=1`,
          params: { id: event.id, layer: event.layer },
        }),
        m(EventInfo, event),
        event.images.length > 0 ? m(ImageCarousel, { images: event.images }) : null,
        m(Registration, event),
      ]
    }
  }
}