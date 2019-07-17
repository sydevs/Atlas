
L.Control.Sidebar = L.Control.extend({
  includes: (L.Evented.prototype || L.Mixin.Events),
  options: {},

  initialize: function(options) {
    L.setOptions(this, options)

    let ids = ['search', 'list', 'details', 'register', 'result']
    ids.forEach(id => {
      panel = L.DomUtil.get('sidebar-'+id)
      console.log('sidebar-'+id, panel)
      L.DomUtil.addClass(panel, 'leaflet-control')
    })

    let content = L.DomUtil.get(options.container)
    content.parentNode.removeChild(content)
    this._contentContainer = content

    let container = L.DomUtil.create('div', 'leaflet-sidebar visible')
    L.DomUtil.addClass(content, 'leaflet-control')
    container.innerHTML = content.innerHTML
    this._container = container

    this._toggleButton = L.DomUtil.create('a', 'leaflet-sidebar-close', content)
    this._toggleButton.innerHTML = '&times;'
  },

  addTo: function(map) {
    let container = this._container
    this._map = map

    L.DomEvent.on(this._toggleButton, 'click', function(event) {
      this.toggle(false)
      L.DomEvent.stopPropagation(event)
    }, this)

    // Attach sidebar container to controls container
    map._controlContainer.insertBefore(container, map._controlContainer.firstChild);

    // Make sure we don't drag the map when we interact with the content
    let stop = L.DomEvent.stopPropagation
    let fakeStop = L.DomEvent.fakeStop || L.DomEvent._fakeStop || stop
    L.DomEvent.on(container, 'contextmenu', stop)
    L.DomEvent.on(container, 'click', fakeStop)
    L.DomEvent.on(container, 'mousedown', stop)
    L.DomEvent.on(container, 'touchstart', stop)
    L.DomEvent.on(container, 'dblclick', fakeStop)
    L.DomEvent.on(container, 'mousewheel', stop)
    L.DomEvent.on(container, 'MozMousePixelScroll', stop)

    this.toggle(true)

    return this
  },

  removeFrom: function(map) {
    // We never need to do this.
    console.error('There is no support for removing the sidebar control')
    return this
  },

  isVisible() {
    return L.DomUtil.hasClass(this._container, 'visible');
  },

  toggle(show = null) {
    let offset = this._container.offsetWidth / 2
    if (show == null) show = !this.isVisible()
    if (show) {
      L.DomUtil.removeClass(this._container, 'visible')
      this._map.panBy([-offset, 0], { duration: 0.5 })
    } else {
      L.DomUtil.removeClass(this._container, 'visible')
      this._map.panBy([offset, 0], { duration: 0.5 })
    }
  },
})

L.control.sidebar = function(options) {
  return new L.Control.Sidebar(options)
}
