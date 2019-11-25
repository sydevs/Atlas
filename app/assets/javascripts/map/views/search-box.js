/* globals Application, GeoSearchAPI */
/* exported SearchBox */

class SearchBox {

  constructor(element) {
    this.container = element
    this.geoSearch = new GeoSearchAPI()
    this.searchResults = element.querySelector('.js-search-results')
    this.searchInput = element.querySelector('.js-search-input')
    this.searchInput.addEventListener('input', () => this.refreshGeoSearch())
    this.searchResults.addEventListener('click', event => {
      if (event.target.tagName == 'LI') {
        this.select(JSON.parse(event.target.dataset.parameters))
      }
    })

    this.enableGeoSearch = true
  }

  select(location) {
    this.enableGeoSearch = false
    this.searchInput.value = null
    this.searchInput.placeholder = location.label
    this.searchResults.innerHTML = null
    this.enableGeoSearch = true

    Application.loadEvents({
      latitude: location.latitude,
      longitude: location.longitude
    })
  }

  refreshGeoSearch() {
    const searchText = this.searchInput.value
    this.searchResults.innerHTML = null

    if (searchText.length < 3 || !this.enableGeoSearch) {
      return
    }

    this.geoSearch.query(searchText, results => {
      results.forEach(result => {
        const element = document.createElement('LI')
        element.dataset.parameters = JSON.stringify(result)
        element.innerText = result.label
        this.searchResults.appendChild(element)
      })
    })
  }

}
