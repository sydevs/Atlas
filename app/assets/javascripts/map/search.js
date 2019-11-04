const Search = {
  infoPanelElement: null,
  registrationPanelElement: null,
  boxShadowDivElement: null,
  currentEvent: null,
  currentEvents: [],
  searchResultsContainer: null,
  searchContainer: null,
  load() {
    Search.infoPanelElement = document.getElementById("infoPanel");
    Search.registrationPanelElement = document.getElementById("registrationPanel");
    Search.boxShadowDivElement = document.getElementById("boxShadowDiv");
    Search.searchResultsContainer = document.getElementById("searchResultsContainer");
    Search.searchContainer = document.getElementById("searchContainer");
    Search.setCurrentEvents();

    document.getElementById('lessInfoLink').addEventListener("click", Search._onLessInfoLinkClick);
    document.getElementById('cancelRegisterLink').addEventListener("click", Search._onCancelRegisterLinkClick);
    document.getElementById('showListLink').addEventListener("click", Search._onShowListMobileLink);

    Search._addRegisterMoreInfoListeners()
  },
  clearSearchDiv() {
    searchResultsContainer.innerHTML = '';

    Search._decreaseBoxShadowDiv();

    Search.searchContainer.classList.remove("show-list-mobile-results")

    Search.toggleDisplayClass(Search.boxShadowDivElement, "none");
    Search.toggleDisplayClass(Search.infoPanelElement, "none");
    Search.toggleDisplayClass(Search.registrationPanelElement, "none");
  },
  setCurrentEvents(filteredResults) {
    var events = filteredResults ? filteredResults : Data.events;
    Search.searchResultsContainer.innerHTML = '';
    if (Data.events.length > 0) {
      for(var i = 0; i < events.length; i++) {
        Search.searchResultsContainer.innerHTML += Templates.resultContainerHtml(i, events[i]);
        Search._addRegisterMoreInfoListeners()
      }
    } else {
      Search.searchResultsContainer.innerHTML = '<div class="result-container event-name">No Results Found</div>';
      Search.toggleDisplayClass(Search.boxShadowDivElement, "none");
    }
    Search.currentEvents = events;
  },
  _onShowListMobileLink(clickEvent) {
    clickEvent.preventDefault();
    Search.searchContainer.classList.add("show-list-mobile-results")
  },
  _addRegisterMoreInfoListeners() {
    var registerButtons = document.getElementsByClassName('registerButton');

    for (var i = 0; i < registerButtons.length; i++) {
      registerButtons[i].addEventListener('click', Search._onRegistrationButtonClick);
    }

    var moreInfoLinks = document.getElementsByClassName('moreInfoLink');
    for (var i = 0; i < moreInfoLinks.length; i++) {
      moreInfoLinks[i].addEventListener("click", Search._onMoreInfoLinkClick);
    }
  },
  _setCurrentEvent(eventIndex) {
    Search.currentEvent = Data.events[eventIndex];
  },
  _onMoreInfoLinkClick(clickEvent) {
    clickEvent.preventDefault();
    Search._increaseBoxShadowDiv();
    Search._setCurrentEvent(parseInt(clickEvent.target.getAttribute("data-eventIndex")))
    Search._setInfoPanelData();
    Search.toggleDisplayClass(Search.registrationPanelElement, "none");
    Search.toggleDisplayClass(Search.infoPanelElement, "block");
  },
  _onLessInfoLinkClick(clickEvent) {
    clickEvent.preventDefault();
    Search._decreaseBoxShadowDiv();
    Search.toggleDisplayClass(Search.infoPanelElement, "none");
  },
  _onCancelRegisterLinkClick(clickEvent) {
    clickEvent.preventDefault();
    Search._decreaseBoxShadowDiv();
    Search.toggleDisplayClass(Search.registrationPanelElement, "none");
  },
  _onRegistrationButtonClick(clickEvent) {
    clickEvent.preventDefault();
    Search._increaseBoxShadowDiv();
    Search._setCurrentEvent(parseInt(clickEvent.target.getAttribute("data-eventIndex")))
    Search._setRegistrationData();
    Search.toggleDisplayClass(Search.infoPanelElement, "none");
    Search.toggleDisplayClass(Search.registrationPanelElement, "block");
  },
  _setInfoPanelData() {
    document.getElementById("infoPanelEventName").innerText = Search.currentEvent.name || Search.currentEvent.label;
    document.getElementById("infoPanelEventDescription").innerText = Search.currentEvent.description;
  },
  _setRegistrationData() {
    document.getElementById("registrationPanelDescription").innerText = Search.currentEvent.name || Search.currentEvent.label;
  },
  _increaseBoxShadowDiv() {
    Search.boxShadowDivElement.classList.add("width-panel-double");
  },
  _decreaseBoxShadowDiv() {
    Search.boxShadowDivElement.classList.remove("width-panel-double");
  },
  toggleDisplayClass(element, cssClass) {
    element.style.display = cssClass;
  },
}
