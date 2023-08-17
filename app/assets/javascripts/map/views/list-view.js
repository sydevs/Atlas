/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let offlineEventCount = null
  let onlineOnly = false
  let events = undefined

  function updateEvents() {
    let filter = onlineOnly ? 'online' : 'all'
    let getEventIds = Promise.resolve(null)
    console.log('get events', filter)

    if (filter != 'online') {
      getEventIds = AtlasApp.map.getRenderedEventIds()
    }

    getEventIds.then(ids => {
      offlineEventCount = ids && ids.length

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
    oncreate: function() {
      AtlasApp.map.addEventListener('update', updateEvents)
    },
    view: function(vnode) {
      let list = null
      onlineOnly = vnode.attrs.onlineOnly

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
        Util.isDevice('mobile') &&
          m(Navigation, {
            items: [{
              label: Util.translate('navigation.mobile.back'),
              href: '/',
            }]
          }),
        !Util.isDevice('mobile') && onlineOnly &&
          m('.sya-pills', [
            m(m.route.Link, {
              class: 'sya-pill sya-pill--online sya-pill--button sya-pill--active',
              href: '/events',
            }, [
              Util.translate('navigation.mobile.online'),
              m('i.sya-icon.sya-icon--close'),
            ]),
          ]),
        !onlineOnly && offlineEventCount === 0 ?
          m(ListFallback)
          : m('.sya-list', list),
      ]
    }
  }
}