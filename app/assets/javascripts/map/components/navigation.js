/* exported Navigation */

/* global m */

const Navigation = {
  view: function(vnode) {
    return m('.navigation',
      vnode.attrs.items.map(function([label, url, active]) {
        let classes = ['navigation__item']
        if (active) classes.push('navigation__item--active')
        return m(m.route.Link, { class: classes.join(' '), href: url }, label)
      })
    )
  }
}
