/* global L */

L.Control.Searchbox = L.Control.extend({
  includes: (L.Evented.prototype || L.Mixin.Events),
  options: {
    position: 'left',
  },

  onAdd: function(map) {
    let searchbox = L.DomUtil.create('div', 'leaflet-searchbox')
    searchbox.innerHTML = '<span id="sidebar-button">LIST</span><input id="search" type="search" placeholder="Search...">'
    return searchbox
  },

  removeFrom: function(map) {
    // We never need to do this.
    console.error('There is no support for removing the searchbox control') // eslint-disable-line no-console
  },
})

L.control.searchbox = function(options) {
  return new L.Control.Searchbox(options)
}
