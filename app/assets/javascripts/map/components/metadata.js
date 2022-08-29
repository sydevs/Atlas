/* exported Metadata */

/* global m */

const Metadata = {
  view: function(vnode) {
    const data = Object.assign({
      "@context": "https://schema.org",
    }, vnode.attrs.data)

    return m('script', { type: 'application/ld+json' }, JSON.stringify(data))
  }
}
