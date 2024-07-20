/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let offlineEventCount = null
  let onlineOnly = false
  let events = undefined
  let request = null

  function updateEvents() {
    let filter = onlineOnly ? 'online' : 'all'
    let getEventIds

    if (filter != 'online') {
      getEventIds = AtlasApp.map.getRenderedEventIds()
    } else {
      getEventIds = DataRequest.resolve(null)
    }

    pendingRequest = getEventIds.then(ids => {
      offlineEventCount = ids && ids.length

      let promise = AtlasApp.data.getList(filter, ids)
      const dataRequest = new DataRequest(promise)
      request = dataRequest
      dataRequest.then(response => {
        events = response
        if (dataRequest === request) request = null
        m.redraw()
      })
    }).catch(() => {
      events = null
      offlineEventCount = 0
    }).finally(() => {
      m.redraw()
    })
  }

  return {
    oncreate: function() {
      AtlasApp.map.addEventListener('update', Util.throttle(updateEvents, 500))
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
        request ?
          m(Loader, { type: 'small', error: request.resolved ? Util.translate('list.error') : null })
          : null,
        !onlineOnly && offlineEventCount === 0 ?
          m(ListFallback)
          : m('.sya-list', list),
      ]
    }
  }
}