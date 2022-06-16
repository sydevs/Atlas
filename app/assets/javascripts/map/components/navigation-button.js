/* exported NavigationButton */

/* global m */

const NavigationButton = {
  view: function(vnode) {
    return m(m.route.Link,
      {
        href: vnode.attrs.url,
        class: `navigation-button navigation-button--${vnode.attrs.float || 'static'}`
      },
      m(`.icon.icon--${vnode.attrs.icon}`)
    )
  }
}
