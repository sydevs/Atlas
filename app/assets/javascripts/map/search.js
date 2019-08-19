
const Search = {
	infoPanelElement: null,
	boxShadowDivElement: null,
  load() {
    Search.infoPanelElement = document.getElementById("infoPanel");
    Search.boxShadowDivElement = document.getElementById("boxShadowDiv");

		document.getElementById('moreInfoLink').addEventListener("click", Search._onMoreInfoLinkClick);
		document.getElementById('lessInfoLink').addEventListener("click", Search._onLessInfoLinkClick);
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
