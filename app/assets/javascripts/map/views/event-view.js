/* exported EventView */

/* global m, Loader, EventInfo, ImageCarousel, Registration, NavigationButton, BackNavigationButton, App, Util */

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
    onupdate: function() {
      const id = m.route.param('id')
      if (id != event.id) {
        AtlasApp.data.getRecord(AtlasEvent, id).then(response => {
          event = response
          m.redraw()
        })
      }
    },
    view: function() {
      if (!event) return m(Loader)

      let href = '/:model/:id'
      let params = {}

      console.log('render event', event)

      if (event.location.getEventIds(event.layer).length > 1) {
        params['model'] = event.location.type.toLowerCase()
        params['id'] = event.location.id
      } else if (AtlasApp.config.search) {
        href = '/'
      } else {
        params['model'] = 'area'
        params['id'] = event.location.area.id
      }

      return [
        //m(EventMetadata, { event: event }),
        m(BackNavigationButton, {
          float: 'left',
          icon: 'left',
          href: href,
          params: params,
        }),
        m(NavigationButton, {
          float: 'right',
          icon: 'share',
          href: Util.modifyURLParameters(m.route.get(), ['share=1']),
        }),
        m(EventInfo, event),
        event.images.length > 0 ? m(ImageCarousel, { images: event.images }) : null,
        event.category != 'inactive' ? m(Registration, event) : null,
      ]
    }
  }
}