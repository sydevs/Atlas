
/* global m, AtlasAPI */
/* exported App */

const App = {}

document.addEventListener('resize', () => {
  m.redraw()
})

document.addEventListener('DOMContentLoaded', () => {
  App.atlas = new AtlasAPI()
})