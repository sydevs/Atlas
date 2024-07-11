/* exported SimpleCard */
/* global m, Util */

function SimpleCard() {
  return {
    view: function(vnode) {
      console.log("simple card", vnode.attrs)
      
      return m(m.route.Link,
        {
          class: `sya-card sya-card--simple ${vnode.attrs.class}`,
          href: '/:model/:id',
          params: {
            model: vnode.attrs.model,
            id: vnode.attrs.id,
          },
        },
        m('.sya-card__content',
          m('.sya-card__title', vnode.attrs.label),
          vnode.attrs.sublabel ? m('.sya-card__subtitle', vnode.attrs.sublabel) : null,
        ),
        m('a.sya-card__action',
          m('span', vnode.attrs.count),
          m('i.sya-icon.sya-icon--right')
        )
      )
    }
  }
}
