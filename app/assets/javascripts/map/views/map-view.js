/* exported MapView */

/* global m, Search, Navigation, Util */

function MapView() {
  let offlineEventsCount = null

  return {
    view: function() {
      if (!Util.isDevice('mobile')) {
        m.route.set('/events', {}, { replace: true })
      }

      return [
        m(Search, { floating: true }),
        Util.isDevice('mobile') &&
          m('.sya-pill.sya-pill--float.sya-pill--button.sya-pill--online',
            m(m.route.Link, { href: '/online' }, Util.translate('navigation.mobile.online'))
          ),
        Util.isDevice('mobile') && offlineEventsCount === 0 &&
          m(ListFallback),
        Util.isDevice('mobile') && offlineEventsCount >= 0 &&
          m(Navigation, {
            items: [{
              label: Util.translate('navigation.mobile.offline').toUpperCase(),
              href: '/events',
            }]
          }),
      ]
    }
  }
}