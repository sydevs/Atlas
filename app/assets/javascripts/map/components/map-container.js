/* exported MapContainer */
/* global m, MapFrame */

function MapContainer() {
  let mapFrame
  
  return {
    oncreate: function() {
      mapFrame = new MapFrame('map')
    },
    onupdate: function() {
      mapFrame.resize()
    },
    onremove: function() {
      mapFrame.destroy()
    },
    view: function(vnode) {
      return m('#map.map', {
        'class': vnode.attrs.mode ? `map--${vnode.attrs.mode}` : null,
      })
    }
  }
}