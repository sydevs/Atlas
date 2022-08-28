/* exported SimpleCard */
/* global m, Util */

function SimpleCard() {
  return {
    view: function(vnode) {
      const place = vnode.attrs.place
      
      return m(m.route.Link,
        {
          class: `card card--simple ${vnode.attrs.class}`,
          href: '/:layer/:model/:id',
          params: {
            layer: vnode.attrs.layer,
            model: vnode.attrs.model,
            id: vnode.attrs.id,
          },
        },
        m('.card__content',
          m('.card__title', vnode.attrs.label),
        ),
        m('a.card__action',
          m('span', vnode.attrs.count),
          m('i.icon.icon--right')
        )
      )
    }
  }
}
