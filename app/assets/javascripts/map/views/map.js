/* exported MapView */

/* global m, Search, Navigation */

const MapView = {
  view: function() {
    return [
      m(Search, { floating: true }),
      m(Navigation, {
        items: ['offline', 'online'].map((mode) => [mode, `/list/${mode}`])
      }),
    ]
  }
}