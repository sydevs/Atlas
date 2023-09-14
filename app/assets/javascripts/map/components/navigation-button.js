/* exported NavigationButton */

/* global m */

const NavigationButton = {
  view: function(vnode) {
    return m(m.route.Link,
      {
        href: vnode.attrs.href,
        params: vnode.attrs.params,
        class: `sya-navigation-button sya-navigation-button--${vnode.attrs.float || 'static'}`,
        onclick: vnode.attrs.onclick,
        onclick: function() {
          let href_parts = vnode.attrs.href.split('#')
          if (AtlasApp.map && href_parts.length >= 2) {
            AtlasApp.map.setPositionToAnchor(href_parts[1])
          }
        },
      },
      m(`.sya-icon.sya-icon--${vnode.attrs.icon}`)
    )
  }
}

const BackNavigationButton = {
  view: function(vnode) {
    let backPath = m.route.param('back')
    if (backPath) {
      vnode.attrs.href = backPath
      vnode.attrs.params = {}
    }

    vnode.attrs.onclick = function() {
      let href_parts = vnode.attrs.href.split('#')
      if (AtlasApp.map && href_parts.length >= 2) {
        AtlasApp.map.setPositionToAnchor(href_parts[1])
      }
    }

    return m(NavigationButton, vnode.attrs)
  }
}
