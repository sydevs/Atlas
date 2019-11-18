/* global L, Data */
/* exported Map */

const Map = {
  instance: null,

  load() {
    console.log('loading map.js') // eslint-disable-line no-console

    Map.instance = L.map('mapid').setView([Data.currentLocation.lat, Data.currentLocation.lng], 11)

    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 18,
      id: 'mapbox.streets',
      accessToken: window.mbid,
    }).addTo(Map.instance)
  },
}