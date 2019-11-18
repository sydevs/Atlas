const AutoComplete = {
  geoSearchService: null,
  searchResults: [],
  currentMarkers: [],
  currentMarkersGroup: null,
  currentBounds: null,
  markersGroup: null,
  searchAreaButton: null,
  searchAreaContainer: null,
  searchCloseButton: null,
  load() {
    AutoComplete.geoSearchService = new GeoSearch.OpenStreetMapProvider()

    AutoComplete.searchAreaButton = document.getElementById('searchAreaButton')
    AutoComplete.searchAreaContainer = document.getElementById('searchArea')
    AutoComplete.currentMarkersGroup = L.featureGroup(AutoComplete.currentMarkers).addTo(Map.instance)
    AutoComplete._createMarkers(Data.currentLocation.lat, Data.currentLocation.lng)
    AutoComplete.searchCloseButton = document.getElementById('searchCloseButton')

    AutoComplete._autocomplete(document.getElementById('myInput'), AutoComplete.searchResults)
    AutoComplete.currentBounds = Map.instance.getBounds()
    AutoComplete.searchAreaButton.addEventListener('click', AutoComplete._onSearchAreaClick)
  },
  _createMarkers(lat, lng) {
    Utils.getUrl('/api/events.json?latitude=' + lat + '&longitude=' + lng + '&radius=50', AutoComplete._placesApi)
  },
  _createMarkersFromBounds(mapBounds) {
    if (!AutoComplete._currentBoundsCheck(mapBounds)){
      AutoComplete._setCurrentBounds(mapBounds)
      const southWestBound = mapBounds.getSouthWest()
      const northEastBound = mapBounds.getNorthEast()
      Utils.getUrl(
        '/api/events.json?from_bounds=true' +
        '&south_west_point_lat=' + southWestBound.lat +
        '&south_west_point_lng=' + southWestBound.lng +
        '&north_east_point_lat=' + northEastBound.lat +
        '&north_east_point_lng=' + northEastBound.lng
        , AutoComplete._placesApi)
    }
  },
  _setCurrentBounds(mapBounds) {
    AutoComplete.currentBounds = mapBounds
  },
  _currentBoundsCheck(mapBounds){
    return AutoComplete.currentBounds.equals(mapBounds)
  },
  _onSearchAreaClick(event){
    event.preventDefault()
    const mapBounds = Map.instance.getBounds()
    AutoComplete._createMarkersFromBounds(mapBounds)
  },
  _placesApi(xhttp) {
    eventsData = JSON.parse(xhttp.response)
    AutoComplete._resetMarkers()

    var venuesAlreadyMarked = []
    for (var i = 0; i < eventsData.length; i++) {
      var venueId = eventsData[i].venue_id
      if (!venuesAlreadyMarked.includes(venueId)) {
        AutoComplete.currentMarkers.push(
          L.marker([eventsData[i].latitude, eventsData[i].longitude], { venueId: venueId })
        )
        venuesAlreadyMarked.push(venueId)
      }
    }

    Data.events = eventsData
    Search.setCurrentEvents()
    Search.searchContainer.classList.remove('single-marker-mobile-result')

    AutoComplete.currentMarkersGroup = L.featureGroup(AutoComplete.currentMarkers)

    AutoComplete.markersGroup = L.markerClusterGroup({'spiderfyOnMaxZoom': false})
    AutoComplete.markersGroup.addLayers(AutoComplete.currentMarkers)
    Map.instance.addLayer(AutoComplete.markersGroup)

    AutoComplete.currentMarkersGroup.on('click', function(event){
      var venueId = event.layer.options.venueId
      Search.setCurrentEvents(Data.events.filter(element => element.venue_id === venueId))
      Search.searchContainer.classList.add('single-marker-mobile-result')
    }.bind(this))

    if (AutoComplete.currentMarkers.length > 0) {
      Map.instance.fitBounds(AutoComplete.currentMarkersGroup.getBounds())
      AutoComplete.currentBounds = Map.instance.getBounds()
    }
  },
  _hideSearchArea() {
    Search.toggleDisplayClass(AutoComplete.searchAreaButton, 'none')
    Utils.toggleZindex(AutoComplete.searchAreaContainer, 0)
  },
  _showSearchArea() {
    Search.toggleDisplayClass(AutoComplete.searchAreaButton, 'block')
    Utils.toggleZindex(AutoComplete.searchAreaContainer, 999)
  },
  _resetMarkers() {
    AutoComplete.currentMarkers = []
    if (AutoComplete.markersGroup){
      AutoComplete.markersGroup.clearLayers()
    }
    Map.instance.removeLayer(AutoComplete.currentMarkersGroup)
  },  
  _autocomplete(searchTextInput) {
    var currentFocus
    // Bulk of Autocomplete code from: https://www.w3schools.com/howto/howto_js_autocomplete.asp
    searchTextInput.addEventListener('input', function (e) {
      if (this.value.length > 1) {
        AutoComplete._hideSearchArea()
        var autocompleteResultsContainerElement
        var eachAutoCompleteResultElement
        var currentSearchTextInputValue = this.value
        var geoSearchRequest = {
          query: this.value
        }
        AutoComplete.geoSearchService.search(geoSearchRequest).then(function (results, status) {
          AutoComplete.searchResults = []
          // Showing only 8 results for now, potentially increase/descrease the number
          for (var i = 0; i < Math.min(results.length, 8); i++) {
            AutoComplete.searchResults.push(
              {
                'label': results[i].label,
                'lat': results[i].y,
                'lng': results[i].x
              }
            )
          }

          closeAllLists()
          if (!currentSearchTextInputValue) {
            return false
          }
          currentFocus = -1
          /*create a DIV element that will contain the items (values):*/
          autocompleteResultsContainerElement = document.createElement('DIV')
          autocompleteResultsContainerElement.setAttribute('id', this.id + 'autocomplete-list')
          autocompleteResultsContainerElement.setAttribute('class', 'autocomplete-items')
          if (Search.currentEvents.length === 0 || (Data.events.length === Search.currentEvents.length && L.Browser.mobile)) {
            autocompleteResultsContainerElement.setAttribute('style', 'position:initial!important')
          }
          /*append the DIV element as a child of the autocomplete container:*/
          this.parentNode.parentNode.appendChild(autocompleteResultsContainerElement)
          /*for each item in the array...*/
          for (i = 0; i < AutoComplete.searchResults.length; i++) {
            /*create a DIV element for each matching element:*/
            eachAutoCompleteResultElement = document.createElement('DIV')
            /*make the matching letters bold:*/
            eachAutoCompleteResultElement.innerHTML = '<strong>' + AutoComplete.searchResults[i].label.substr(0, currentSearchTextInputValue.length) + '</strong>';
            eachAutoCompleteResultElement.innerHTML += AutoComplete.searchResults[i].label.substr(currentSearchTextInputValue.length)
            /*insert a input field that will hold the current searchResultsay item's value:*/
            eachAutoCompleteResultElement.innerHTML += '<input type=\'hidden\' value=\'' + JSON.stringify(AutoComplete.searchResults[i]) + '\'>';
            /*execute a function when someone clicks on the item value (DIV element):*/
            eachAutoCompleteResultElement.addEventListener('click', function (e) {
              /*insert the value for the autocomplete text field:*/
              var currentResultData = JSON.parse(this.getElementsByTagName('input')[0].value)
              searchTextInput.value = currentResultData.label
              Map.instance.panTo([currentResultData.lat, currentResultData.lng])
              AutoComplete._createMarkers(currentResultData.lat, currentResultData.lng)
              Search.toggleDisplayClass(Search.boxShadowDivElement, 'block')
              /*close the list of autocompleted values,
              (or any other open lists of autocompleted values:*/
              closeAllLists()
            })
            autocompleteResultsContainerElement.appendChild(eachAutoCompleteResultElement)
          }
        }.bind(this))
      } else {
        closeAllLists()
        AutoComplete.searchResults = []
        if (Data.events.length === 0){
          Search.clearSearchDiv()
        }
      }
    })

    AutoComplete.searchCloseButton.addEventListener('click', function (e) {
      document.getElementById('myInput').value = ''
      AutoComplete._showSearchArea()
      Search.searchContainer.classList.remove('single-marker-mobile-result')
      Search.searchContainer.classList.remove('show-list-mobile-results')
      Search.clearSearchDiv()
    })

    /*execute a function presses a key on the keyboard:*/
    searchTextInput.addEventListener('keydown', function (e) {
      var x = document.getElementById(this.id + 'autocomplete-list')
      if (x) x = x.getElementsByTagName('div')
      if (e.keyCode == 40) {
        /*If the arrow DOWN key is pressed,
        increase the currentFocus variable:*/
        currentFocus++
        /*and and make the current item more visible:*/
        addActive(x)
      } else if (e.keyCode == 38) { //up
        /*If the arrow UP key is pressed,
        decrease the currentFocus variable:*/
        currentFocus--
        /*and and make the current item more visible:*/
        addActive(x)
      } else if (e.keyCode == 13) {
        /*If the ENTER key is pressed, prevent the form from being submitted,*/
        e.preventDefault()
        if (currentFocus > -1) {
          /*and simulate a click on the "active" item:*/
          if (x) x[currentFocus].click()
        }
      }
    })

    function addActive(x) {
      /*a function to classify an item as "active":*/
      if (!x) return false
      /*start by removing the "active" class on all items:*/
      removeActive(x)
      if (currentFocus >= x.length) currentFocus = 0
      if (currentFocus < 0) currentFocus = (x.length - 1)
      /*add class "autocomplete-active":*/
      x[currentFocus].classList.add('autocomplete-active')
    }

    function removeActive(x) {
      /*a function to remove the "active" class from all autocomplete items:*/
      for (var i = 0; i < x.length; i++) {
        x[i].classList.remove('autocomplete-active')
      }
    }

    function closeAllLists(elmnt) {
      /*close all autocomplete lists in the document,
      except the one passed as an argument:*/
      var x = document.getElementsByClassName('autocomplete-items')
      for (var i = 0; i < x.length; i++) {
        if (elmnt != x[i] && elmnt != searchTextInput) {
          x[i].parentNode.removeChild(x[i])
        }
      }
    }

    document.addEventListener('click', function (e) {
      closeAllLists(e.target)
    })
  },
}
