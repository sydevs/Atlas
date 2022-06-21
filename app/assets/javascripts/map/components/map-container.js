/* exported MapContainer */
/* global m, MapFrame */

function MapContainer() {
  let map
  let selectionId
  let selectionModel

  function updateSelection(attrs) {
    if (attrs.selectionId != selectionId || attrs.selectionModel != selectionModel) {
      selectionId = attrs.selectionId
      selectionModel = attrs.selectionModel

      App.atlas.getRecord(selectionModel, selectionId).then(function(record) {
        if (selectionModel == 'event') record = record.location
        map.setSelection(record)
      })
    }
  }

  return {
    oncreate: function(vnode) {
      map = new MapFrame('map', {
        onload: () => updateSelection(vnode.attrs)
      })
    },
    onupdate: function(vnode) {
      if (map.loading) return

      updateSelection(vnode.attrs)
      map.resize()
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