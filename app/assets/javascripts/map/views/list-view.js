/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let offlineEventCount = null
  let events = undefined

  function updateEvents(online = null) {
    let filter = online ? 'online' : 'all'
    let getEventIds = Promise.resolve(null)

    if (filter != 'online') {
      getEventIds = AtlasApp.map.getRenderedEventIds()
    }

    getEventIds.then(ids => {
      offlineEventCount = ids.length

      return AtlasApp.data.getList(filter, ids).then(response => {
        events = response
      })
    }).catch(() => {
      events = null
    }).finally(() => {
      m.redraw()
    })
  }

  return {
    oncreate: function(vnode) {
      AtlasApp.map.addEventListener('update', () => {
        updateEvents(vnode.attrs.onlineOnly)
      })
    },
    view: function(vnode) {
      let list = null

      if (events == undefined) {
        list = m(Loader)
      } else if (events && events.length > 0) {
        list = events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'sya-list__item', event: event })
        })
      } else if (vnode.attrs.layer == AtlasEvent.LAYER.offline) {
        list = m(ListFallback)
      }

      return [
        m(Search),
        Util.isDevice('mobile') && m(Navigation, {
          items: [{
            label: Util.translate('navigation.mobile.back'),
            href: '/',
          }]
        }),
        offlineEventCount === 0 && m('p.sya-list-fallback', "No local events available"),
        m('.sya-list', list),
      ]
    }
  }
}