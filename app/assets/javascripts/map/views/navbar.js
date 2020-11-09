/* globals Application, GeoSearchAPI */
/* exported Navbar */

class Navbar {

  constructor(element) {
    this.container = element

    this.venueBack = document.getElementById('js-venue-back')
    this.venueText = document.getElementById('js-venue-title')

    this.geoSearch = new GeoSearchAPI(this.container.dataset.key, this.container.dataset.country || null)
    this.searchResults = document.getElementById('js-search-results')
    this.searchInput = document.getElementById('js-search-input')
    this.searchPlaceholder = this.searchInput.placeholder
    this.enableGeoSearch = true

    this.venueBack.addEventListener('click', _event => this.clearVenue())
    this.searchResults.addEventListener('click', event => this.handleSearchResultClick(event.target))
    this.searchInput.addEventListener('input', _event => this.refreshGeoSearch())
    this.searchInput.addEventListener('keydown', event => this.handleKeyPress(event.code, event.keyCode))
    this.searchInput.addEventListener('focus', _event => {
      if (this.searchInput.value.length >= 3) {
        this.setActive(true)
      }
    })

    if (this.searchInput.value) {
      this.refreshGeoSearch()
    }
  }

  setText(text) {
    this.searchInput.placeholder = text || this.searchPlaceholder
  }

  select(location) {
    this.focusedItem = null
    this.enableGeoSearch = false
    this.searchInput.value = null
    this.searchResults.innerHTML = null
    this.enableGeoSearch = true

    if (location) {
      this.searchInput.placeholder = location.label || this.searchPlaceholder

      if (location.west && location.east && location.north && location.south) {
        Application.map.fitTo(location)
      } else {
        Application.map.flyTo(location, location.zoom || 11)
      }
    } else {
      this.searchInput.placeholder = this.searchPlaceholder
    }
  }

  setActive(active) {
    const isActive = this.container.classList.contains('navbar--active')
    if (isActive == active) return

    this.container.classList.toggle('navbar--active', active)
  }

  refreshGeoSearch() {
    const searchText = this.searchInput.value

    if (searchText.length < 3 || !this.enableGeoSearch) {
      this.setActive(false)
      return
    }

    this.container.classList.add('navbar--loading')

    const center = Application.map.getCenter()
    this.geoSearch.query(searchText, [center.longitude, center.latitude], results => {
      this.searchResults.innerHTML = null

      results.forEach(result => {
        const element = document.createElement('LI')
        element.tabIndex = '0'
        element.dataset.parameters = JSON.stringify(result)
        element.innerText = result.label
        this.searchResults.appendChild(element)
        this.setActive(true)
      })
      
      setTimeout(() => {
        this.container.classList.remove('navbar--loading')
      }, 1000)
    })
  }

  handleSearchResultClick(target) {
    if (target.tagName == 'LI') {
      this.select(JSON.parse(target.dataset.parameters))
    }
  }

  handleKeyPress(keyName, keyCode) {
    if (keyName == 'Enter' || keyCode === 13) {
      this.selectFocusedElement()
    } else if (event.code == 'ArrowDown' || event.keyCode === 40) {
      this.moveFocusDown()
    } else if (event.code == 'ArrowUp' || event.keyCode === 38) {
      this.moveFocusUp()
    }
  }

  /* ===== VENUE BANNER ===== */

  setVenue(venue) {
    this.venueText.textContent = venue ? venue.label : ''
  }

  clearVenue() {
    Application.back()
  }

  /* ===== SEARCH RESULT FOCUS ===== */

  selectFocusedElement() {
    if (this.focusedItem) {
      this.focusedItem.click()
    } else {
      this.searchResults.firstElementChild.click()
    }
  }

  clearFocus() {
    if (this.focusedItem) {
      this.focusedItem.classList.remove('focus')
      this.focusedItem = null
    }
  }

  moveFocusUp() {
    if (this.focusedItem) {
      this.focusedItem.classList.remove('focus')
      this.focusedItem = this.focusedItem.previousElementSibling
    }

    if (!this.focusedItem) {
      this.focusedItem = this.searchResults.lastElementChild
    }

    if (this.searchResults.childElementCount > 0) {
      this.focusedItem.classList.add('focus')
    }
  }

  moveFocusDown() {
    if (this.focusedItem) {
      this.focusedItem.classList.remove('focus')
      this.focusedItem = this.focusedItem.nextElementSibling
    } 
    
    if (!this.focusedItem) {
      this.focusedItem = this.searchResults.firstElementChild
    }

    if (this.searchResults.childElementCount > 0) {
      this.focusedItem.classList.add('focus')
    }
  }

}
