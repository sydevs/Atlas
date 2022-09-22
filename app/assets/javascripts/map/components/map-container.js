/* exported MapContainer */
/* global m, MapFrame */

function MapContainer() {
  let map
  let selection
  let layer
  let mode

  function updateSelection(id, model, options) {
    if (!selection || selection.id != id || selection.model != model) {
      selection = { id: id, model: model }

      AtlasApp.data.getRecord(selection.model, selection.id).then(function(record) {
        if (selection.model == AtlasEvent) record = record.location
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
      layer = vnode.attrs.layer || AtlasEvent.LAYER.offline
      map = new MapFrame('sya-map', {
        layer: vnode.attrs.layer,
      })

      map.addEventListener('move', () => {
        AtlasApp.data.clearCache('lists')
        AtlasApp.data.clearCache('sortedLists')
      })

      const selection = vnode.attrs.selection || {}
      updateSelection(selection.id, selection.model, { transition: false })
      AtlasApp.map = map
    },
    onupdate: function(vnode) {
      if (map.loading) return

      const selection = vnode.attrs.selection || {}
      updateSelection(selection.id, selection.model)
      updateLayer(vnode.attrs.layer)
      updateMode(vnode.attrs.mode)
    },
    onremove: function() {
      map.destroy()
    },
    view: function(vnode) {
      return m('#sya-map.sya-map', {
        class: vnode.attrs.mode ? `sya-map--${vnode.attrs.mode}` : null,
      })
    }
  }
}