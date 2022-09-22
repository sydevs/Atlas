/* exported Navigation */

/* global m */

const Navigation = {
  view: function(vnode) {
    const items = vnode.attrs.items

    if (vnode.attrs.optional && !items.every(item => item.badge > 0)) {
      return
    }

    return m('.sya-navigation',
      items.map(function(item) {
        let classes = ['sya-navigation__item']
        if (item.active) classes.push('sya-navigation__item--active')
        return m(m.route.Link, {
          class: classes.join(' '),
          href: item.href,
          params: item.params,
          'data-badge': item.badge > 0 ? item.badge : null,
        }, item.label)
      })
    )
  }
}
