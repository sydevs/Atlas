/* exported Search */
/* global m, Util, GeoSearchAPI */

function Search() {
  let focused = false
  let loading = false
  let accessToken = 'pk.eyJ1Ijoic3lkZXZhZG1pbiIsImEiOiJjazczcXV4ZzQwZXJtM3JxZTF6a2g0dW9hIn0.avMfkC306-2PqpNRnz6otg'
  let geoSearch = new GeoSearchAPI(accessToken)
  let results = []

  function onChange() {
    let query = this.value

    if (query.length >= 3) {
      loading = true

      geoSearch.query(query, [0, 0], response => {
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
          //value: query,
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
            'data-parameters': JSON.stringify(result),
          }, result.label)
        }))
      )
    }
  }
}