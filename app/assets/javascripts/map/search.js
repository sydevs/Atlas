const Search = {
  infoPanelElement: null,
  registrationPanelElement: null,
  boxShadowDivElement: null,
  currentEvent: null,
  load() {
    Search.infoPanelElement = document.getElementById("infoPanel");
    Search.registrationPanelElement = document.getElementById("registrationPanel");
    Search.boxShadowDivElement = document.getElementById("boxShadowDiv");

    document.getElementById('lessInfoLink').addEventListener("click", Search._onLessInfoLinkClick);
    document.getElementById('cancelRegisterLink').addEventListener("click", Search._onCancelRegisterLinkClick);

    var registerButtons = document.getElementsByClassName('registerButton');
    for (var i = 0; i < registerButtons.length; i++) {
      registerButtons[i].addEventListener('click', Search._onRegistrationButtonClick);
    }
    var moreInfoLinks = document.getElementsByClassName('moreInfoLink');
    for (var i = 0; i < moreInfoLinks.length; i++) {
      moreInfoLinks[i].addEventListener("click", Search._onMoreInfoLinkClick);
    }
  },
  _setCurrentEvent(eventId) {
    Search.currentEvent = Data.events[eventId];
  },
  _onMoreInfoLinkClick(clickEvent) {
    clickEvent.preventDefault();
    Search._increaseBoxShadowDiv();
    Search._setCurrentEvent(parseInt(clickEvent.target.getAttribute("data-eventId")))
    Search._setInfoPanelData();
    Search._toggleDisplayClass(Search.registrationPanelElement, "none");
    Search._toggleDisplayClass(Search.infoPanelElement, "block");
  },
  _onLessInfoLinkClick(clickEvent) {
    clickEvent.preventDefault();
    Search._decreaseBoxShadowDiv();
    Search._toggleDisplayClass(Search.infoPanelElement, "none");
  },
  _onCancelRegisterLinkClick(clickEvent) {
    clickEvent.preventDefault();
    Search._decreaseBoxShadowDiv();
    Search._toggleDisplayClass(Search.registrationPanelElement, "none");
  },
  _onRegistrationButtonClick(clickEvent) {
    clickEvent.preventDefault();
    Search._increaseBoxShadowDiv();
    Search._setCurrentEvent(parseInt(clickEvent.target.getAttribute("data-eventId")))
    Search._setRegistrationData();
    Search._toggleDisplayClass(Search.infoPanelElement, "none");
    Search._toggleDisplayClass(Search.registrationPanelElement, "block");
  },
  _setInfoPanelData() {
    document.getElementById("infoPanelEventName").innerText = Search.currentEvent.name;
    document.getElementById("infoPanelEventDescription").innerText = Search.currentEvent.description;
  },
  _setRegistrationData() {
    document.getElementById("registrationPanelDescription").innerText = Search.currentEvent.name;
  },
  _increaseBoxShadowDiv() {
    Search.boxShadowDivElement.classList.add("width-panel-double");
  },
  _decreaseBoxShadowDiv() {
    Search.boxShadowDivElement.classList.remove("width-panel-double");
  },
  _toggleDisplayClass(element, cssClass) {
    element.style.display = cssClass;
  },
}
