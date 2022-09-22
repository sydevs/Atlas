/* exported NavigationButton */

/* global m */

const NavigationButton = {
  view: function(vnode) {
    return m(m.route.Link,
      {
        href: vnode.attrs.href,
        params: vnode.attrs.params,
        class: `sya-navigation-button sya-navigation-button--${vnode.attrs.float || 'static'}`
      },
      m(`.sya-icon.sya-icon--${vnode.attrs.icon}`)
    )
  }
}
