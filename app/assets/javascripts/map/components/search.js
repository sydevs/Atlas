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

      let center = App.map.getCenter()
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
      App.map.fitTo(location)
    } else {
      App.map.goTo(location, location.zoom || 11)
    }

    selected = location
  }
  
  return {
    view: function(vnode) {
      let classes = []
      if (focused && results.length > 0) classes.push('search--active')
      if (vnode.attrs.floating) classes.push('search--floating')

      return m('.search', { class: classes.join(' ') },
        m('input.search__input', {
          type: 'text',
          tabindex: 1,
          placeholder: Util.translate('search.prompt'),
          value: selected ? selected.label : null,
          onkeyup: onChange,
          onfocus: () => { focused = true },
          onblur: () => { focused = false },
        }),
        m('.search__icon',
          m('i.icon', {
            class: `icon--${loading ? 'spinner' : 'search'}`,
          })
        ),
        m('ul.search__results', results.map(function(result) {
          return m('li', {
            tabindex: 0,
            onmousedown: () => select(result)
          }, result.label)
        }))
      )
    }
  }
}