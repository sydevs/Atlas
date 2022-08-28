
/* global m, AtlasAPI */
/* exported App */

const App = {
  data: null,
  map: null,
}

document.addEventListener('resize', () => {
  m.redraw()
})

document.addEventListener('DOMContentLoaded', () => {
  App.data = new DataCache()
})
