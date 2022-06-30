/* exported List */
/* global m, EventCard */

function List() {
  return {
    /*onbeforeremove: function(vnode) {
      vnode.dom.classList.add('fadeout')
      return new Promise(function(resolve) {
        vnode.dom.addEventListener('animationend', resolve)
      })
    },*/
    view: function(vnode) {
      return m('.list', vnode.attrs.events.map(function(event) {
        return m(EventCard, { key: event.id, class: 'list__item', event: event })
      }))
    }
  }
}