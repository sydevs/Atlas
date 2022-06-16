
/* global AtlasAPI, MapFrame */

const App = {

  load: function() {
    App.atlas = new AtlasAPI()
    //App.map = new MapFrame('map')
  }

}

document.addEventListener('DOMContentLoaded', () => {
  App.load()
})
