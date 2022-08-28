/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let onlineEventsCount = null
  let events = null
  let layer = null

  function updateEvents() {
    if (layer == AtlasEvent.LAYER.online) {
      return App.data.getList(AtlasEvent.LAYER.online).then(response => {
        events = response
      })
    } else {
      return App.map.getRenderedEventIds().then(eventIds => {
        return eventIds.length > 0 ? App.data.getList(AtlasEvent.LAYER.offline, eventIds) : []
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
    oncreate: function(vnode) {
      layer = m.route.param('layer') || vnode.attrs.layer
      App.map.addEventListener('update', () => {
        updateEvents().finally(() => m.redraw())
      })
    },
    onupdate: function(vnode) {
      updateLayer(m.route.param('layer') || vnode.attrs.layer)
    },
    view: function(vnode) {
      let mobile = Util.isDevice('mobile')
      let list = null

      if (events && events.length > 0) {
        list = m('.list', events.map(function(event) {
          return m(EventCard, { key: event.id, class: 'list__item', event: event })
        }))
      } else if (vnode.attrs.layer == AtlasEvent.LAYER.offline) {
        list = m(ListFallback)
      }

      App.data.getList(AtlasEvent.LAYER.online).then(events => {
        onlineEventsCount = events.length
        m.redraw()
      })

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
        list,
      ]
    }
  }
}