
/* global m, AtlasAPI */
/* exported App */

const App = {
  atlas: null,
  map: null,
}

document.addEventListener('resize', () => {
  m.redraw()
})

document.addEventListener('DOMContentLoaded', () => {
  App.atlas = new AtlasAPI()
})