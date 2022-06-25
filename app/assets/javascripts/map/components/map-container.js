/* exported MapContainer */
/* global m, MapFrame */

function MapContainer() {
  let map
  let selectionId
  let selectionModel
  let layer

  function updateSelection(attrs, options) {
    if (attrs.selectionId != selectionId || attrs.selectionModel != selectionModel) {
      selectionId = attrs.selectionId
      selectionModel = attrs.selectionModel

      App.data.getRecord(selectionModel, selectionId).then(function(record) {
        if (selectionModel == 'event') record = record.location
        map.setSelection(record, options)
      })
    }
  }

  function updateLayer(newLayer) {
    if (layer != newLayer) {
      layer = newLayer
      map.showLayer(layer)
    }
  }

  return {
    oncreate: function(vnode) {
      layer = vnode.attrs.layer || 'offline'
      map = new MapFrame('map', {
        layer: vnode.attrs.layer,
        //onload: () => updateSelection(vnode.attrs, { transition: false })
      })

      map.addEventListener('move', () => App.data.clearCache('sortedLists'))
      map.addEventListener('moveend', () => App.data.clearCache('lists'))

      updateSelection(vnode.attrs, { transition: false })
      App.map = map
    },
    onupdate: function(vnode) {
      if (map.loading) return

      updateSelection(vnode.attrs)
      updateLayer(vnode.attrs.layer)
      //map.resize()
    },
    onremove: function() {
      map.destroy()
    },
    view: function(vnode) {
      return m('#map.map', {
        'class': vnode.attrs.mode ? `map--${vnode.attrs.mode}` : null,
      })
    }
  }
}