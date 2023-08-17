/* exported MapView */

/* global m, Search, Navigation, Util */

function MapView() {
  let offlineEventsCount = null

  return {
    view: function(vnode) {
      if (AtlasApp.map) {
        AtlasApp.map.getRenderedEventIds().then(eventIds => {
          offlineEventsCount = eventIds.length

          if (offlineEventsCount > 0 && !Util.isDevice('mobile')) {
            m.route.set('/events', {}, { replace: true })
          }
        }, _error => {
          offlineEventsCount = null
        }).finally(() => m.redraw())
  
        /*AtlasApp.map.addEventListener('movestart', () => {
          offlineEventsCount = null
          m.redraw()
        })*/
      }

      return [
        m(Search, { floating: true }),
        Util.isDevice('mobile') && m('.sya-pill.sya-pill__floating_button',
          m(m.route.Link, { style: 'color: #6FA4C3', href: '/online' }, Util.translate('navigation.mobile.online'))
        ),
        Util.isDevice('mobile') && 
          offlineEventsCount === 0 ?
          m(ListFallback)
          : m(Navigation, {
            items: [{
              label: Util.translate('navigation.mobile.offline').toUpperCase(),
              href: '/events',
            }]
          }),
      ]
    }
  }
}