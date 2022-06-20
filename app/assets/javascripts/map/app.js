
/* global AtlasAPI */

const App = {

  load: function() {
    App.atlas = new AtlasAPI()
  }

}

document.addEventListener('DOMContentLoaded', () => {
  App.load()
})
