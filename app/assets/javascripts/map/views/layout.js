/* exported Layout */

/* global m, MapContainer, ShareModal */

function Layout() {
  return {
    view: function(vnode) {
      const share = Boolean(m.route.param('share'))
      const layer = m.route.param('layer') || AtlasEvent.LAYER.offline
      const id = m.route.param('id')

      return m('.layout', { class: share ? 'noscroll' : null },
        share ? m(ShareModal) : null,
        m(MapContainer, {
          mode: vnode.attrs.map,
          layer: layer,
          selectionId: id,
          selectionModel: vnode.attrs.model,
        }),
        m('.panel', {
          class: vnode.attrs.panel ? `panel--${vnode.attrs.panel}` : null
        }, m(vnode.attrs.view, {
          layer: layer,
          model: vnode.attrs.model,
        }))
      )
    }
  }
}