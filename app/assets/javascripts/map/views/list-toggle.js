/* globals Application */
/* exported ListToggle */

class ListToggle {

  constructor(element) {
    this.container = element
    this.container.addEventListener('click', () => this.toggle())
  }

  toggle() {
    this.container.classList.toggle('list-toggle--closed')
    this.container.classList.toggle('list-toggle--open')
    Application.map.invalidateSize()
  }

}
