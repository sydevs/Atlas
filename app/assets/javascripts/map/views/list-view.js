/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let onlineEventsCount = null
  let eventIds = []
  let events = undefined
  let layer = AtlasEvent.LAYER.offline

  function updateEvents() {
    if (Util.isDevice('mobile')) {
      if (layer == AtlasEvent.LAYER.online) {
        return AtlasApp.data.getList(AtlasEvent.LAYER.online).then(response => {
          events = response
        })
      } else {
        return AtlasApp.data
          .getList(AtlasEvent.LAYER.online)
          .then((response) => {
            return response;
          })
          .then((onlineData) =>
            AtlasApp.map.getRenderedEventIds().then((ids) => {
              eventIds = ids;
              let offlineData =
                ids.length > 0
                  ? AtlasApp.data.getList(AtlasEvent.LAYER.offline, ids)
                  : [];
              return offlineData;
            }).then((offlineData) => {
              return offlineData.concat(onlineData)
            })
          )
          .then((response) => {
            events = response;
          })
          .catch(() => {
            events = null;
          });
      }
    } else {
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
        m('.sya-list', list),
      ]
    }
  }
}