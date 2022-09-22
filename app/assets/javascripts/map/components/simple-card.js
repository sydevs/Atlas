/* exported SimpleCard */
/* global m, Util */

function SimpleCard() {
  return {
    view: function(vnode) {
      const place = vnode.attrs.place
      
      return m(m.route.Link,
        {
          class: `sya-card sya-card--simple ${vnode.attrs.class}`,
          href: '/:layer/:model/:id',
          params: {
            layer: vnode.attrs.layer,
            model: vnode.attrs.model,
            id: vnode.attrs.id,
          },
        },
        m('.sya-card__content',
          m('.sya-card__title', vnode.attrs.label),
        ),
        m('a.sya-card__action',
          m('span', vnode.attrs.count),
          m('i.sya-icon.sya-icon--right')
        )
      )
    }
  }
}
