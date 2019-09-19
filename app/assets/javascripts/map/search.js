
const Search = {
	infoPanelElement: null,
  registrationPanelElement: null,
	boxShadowDivElement: null,
  load() {
    Search.infoPanelElement = document.getElementById("infoPanel");
    Search.registrationPanelElement = document.getElementById("registrationPanel");
    Search.boxShadowDivElement = document.getElementById("boxShadowDiv");

		document.getElementById('moreInfoLink').addEventListener("click", Search._onMoreInfoLinkClick);
		document.getElementById('lessInfoLink').addEventListener("click", Search._onLessInfoLinkClick);
		document.getElementById('cancelRegisterLink').addEventListener("click", Search._onCancelRegisterLinkClick);
		document.getElementById('registerButton').addEventListener("click", Search._onRegistrationButtonClick);
  },
  _onMoreInfoLinkClick(clickEvent) {
		clickEvent.preventDefault();
		Search._increaseBoxShadowDiv();
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
    Search._toggleDisplayClass(Search.registrationPanelElement, "block");
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
