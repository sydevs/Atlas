/* exported List */
/* global m, EventCard */

function List() {
  return {
    view: function(vnode) {
      return m('.list', vnode.attrs.events.map(function(event) {
        return m(EventCard, { class: 'list__item', event: event })
      }))
    }
  }
}