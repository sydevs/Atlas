/* exported Layout */

/* global m, MapContainer, ShareModal */

function Layout() {
  return {
    view: function(vnode) {
      const share = Boolean(m.route.param('share'))

      return m('.layout', { class: share ? 'noscroll' : null },
        share ? m(ShareModal) : null,
        m(MapContainer, { mode: vnode.attrs.map }),
        m('.panel', { class: vnode.attrs.panel ? `panel--${vnode.attrs.panel}` : null }, vnode.children)
      )
    }
  }
}