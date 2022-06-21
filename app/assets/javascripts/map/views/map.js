/* exported MapView */

/* global m, Search, Navigation, Util */

const MapView = {
  view: function() {
    let device = Util.isDevice('mobile') ? 'mobile' : 'desktop'

    return [
      m(Search, { floating: true }),
      m(Navigation, {
        items: ['offline', 'online'].map(layer => [Util.translate(`navigation.${device}.${layer}`), `/${layer}`])
      }),
    ]
  }
}