/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let onlineEventsCount = null
  let eventIds = []
  let events = undefined
  let layer = null

  function updateEvents() {
    if (layer == AtlasEvent.LAYER.online) {
      return AtlasApp.data.getList(AtlasEvent.LAYER.online).then(response => {
        events = response
      })
    } else {
      return AtlasApp.map.getRenderedEventIds().then(ids => {
        if (Util.areArraysEqual(eventIds, ids)) {
          return events
        } else {
          eventIds = ids
          return ids.length > 0 ? AtlasApp.data.getList(AtlasEvent.LAYER.offline, ids) : []
        }
      }).then(response => {
        events = response
      }).catch(() => {
        events = null
      })
    }
  }

  function updateLayer(newLayer) {
    if (layer != newLayer) {
      layer = newLayer
      updateEvents().finally(() => m.redraw())
    }
  }

  return {
    oninit: function() {
      AtlasApp.data.getList(AtlasEvent.LAYER.online).then(events => {
        onlineEventsCount = events.length
        m.redraw()
      })
    },
    oncreate: function(vnode) {
      layer = m.route.param('layer') || vnode.attrs.layer
      AtlasApp.map.addEventListener('update', () => {
        updateEvents().finally(() => m.redraw())
      })
    },
    onupdate: function(vnode) {
      updateLayer(m.route.param('layer') || vnode.attrs.layer)
    },
    view: function(vnode) {
      let mobile = Util.isDevice('mobile')
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
        m(Navigation, {
          items: mobile ?
            [{
              label: Util.translate('navigation.mobile.back'),
              href: '/',
            }] :
            Object.entries(AtlasEvent.LAYER).map(([key, layer]) => {
              const active = vnode.attrs.layer == layer
              return {
                label: Util.translate(`navigation.desktop.${key}`),
                active: active,
                badge: (key == 'online' && !active) ? onlineEventsCount : null,
                href: '/:layer',
                params: { layer: layer },
              }
            })
        }),
        m('.sya-list', list),
      ]
    }
  }
}