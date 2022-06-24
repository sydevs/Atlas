/* exported Navigation */

/* global m */

const Navigation = {
  view: function(vnode) {
    return m('.navigation',
      vnode.attrs.items.map(function(item) {
        let classes = ['navigation__item']
        if (item.active) classes.push('navigation__item--active')
        return m(m.route.Link, {
          class: classes.join(' '),
          href: item.href,
          'data-badge': item.badge > 0 ? item.badge : null,
        }, item.label)
      })
    )
  }
}
