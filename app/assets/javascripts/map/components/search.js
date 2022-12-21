/* exported Search */
/* global m, Util, GeoSearchAPI */

function Search() {
  let focused = false
  let loading = false
  let accessToken = 'pk.eyJ1Ijoic3lkZXZhZG1pbiIsImEiOiJjazczcXV4ZzQwZXJtM3JxZTF6a2g0dW9hIn0.avMfkC306-2PqpNRnz6otg'
  let geoSearch = new GeoSearchAPI(accessToken)
  let results = []
  let selected = null

  function onChange() {
    let query = this.value
    selected = null

    if (query.length >= 3) {
      loading = true

      let center = AtlasApp.map.getCenter()
      let coords = [center.longitude, center.latitude]
      geoSearch.query(query, coords, response => {
        results = response
        m.redraw()

        setTimeout(() => {
          loading = false
          m.redraw()
        }, 1000)
      })
    } else {
      results = []
    }
  }

  function select(location) {
    if (location.west && location.east && location.north && location.south) {
      AtlasApp.map.fitTo(location)
    } else {
      AtlasApp.map.goTo(location, location.zoom || 11)
    }

    selected = location
  }
  
  return {
    oninit: function() {
      if (AtlasApp.config.query) {
        select(AtlasApp.config.query)
      }
    },
    view: function(vnode) {
      let classes = []
      if (focused && results.length > 0) classes.push('sya-search--active')
      if (vnode.attrs.floating) classes.push('sya-search--floating')

      return m('.sya-search', { class: classes.join(' ') },
        m('input.sya-search__input', {
          type: 'text',
          tabindex: 1,
          placeholder: Util.translate('search.prompt'),
          value: selected ? selected.label : null,
          onkeyup: onChange,
          onfocus: () => { focused = true },
          onblur: () => { focused = false },
        }),
        m('.sya-search__icon',
          m('i.sya-icon', {
            class: `sya-icon--${loading ? 'spinner' : 'search'}`,
          })
        ),
        m('ul.sya-search__results', results.map(function(result) {
          return m('li', {
            tabindex: 0,
            onmousedown: () => select(result)
          }, result.label)
        }))
      )
    }
  }
}