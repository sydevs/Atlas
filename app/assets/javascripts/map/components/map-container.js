/* exported MapContainer */
/* global m, MapFrame */

function MapContainer() {
  let map
  let selectionId
  let selectionModel
  let layer
  let mode

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

  function updateMode(newMode) {
    if (mode != newMode) {
      mode = newMode

      /*if (newMode == 'freeze') {
        map.removeControlLayers()
        map.setFreeze(true)
      } else {
        map.loadControlLayers()
        map.setFreeze(false)
      }*/

      map.resize()
    }
  }

  return {
    oncreate: function(vnode) {
      layer = vnode.attrs.layer || 'offline'
      map = new MapFrame('map', {
        layer: vnode.attrs.layer,
      })

      map.addEventListener('move', () => {
        App.data.clearCache('lists')
        App.data.clearCache('sortedLists')
      })

      updateSelection(vnode.attrs, { transition: false })
      App.map = map
    },
    onupdate: function(vnode) {
      if (map.loading) return

      updateSelection(vnode.attrs)
      updateLayer(vnode.attrs.layer)
      updateMode(vnode.attrs.mode)
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