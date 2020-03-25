/* global Application */
/* exported History */

class History {

  constructor() {
    window.onpopstate = event => this.pop(event)
  }

  push(state) {
    history.pushState(state, undefined, this._create_path(state))
  }

  replace(state) {
    history.replaceState(state, undefined, this._create_path(state))
  }

  pop(event) {
    if (event.state && Application.setState(event.state, false)) {
      event.preventDefault()
    }
  }

  _create_path(state) {
    let path = '/map'

    if (state.event) {
      path += `/event/${state.event.id}`
    } else if (state.venue) {
      path += `/venue/${state.venue.id}`
    } else if (state.query) {
      path += `?q=${state.query}`
      if (state.latitude) path += `&latitude=${state.latitude}`
      if (state.longitude) path += `&longitude=${state.longitude}`
      if (state.zoom) path += `&zoom=${state.zoom}`
      if (state.type) path += `&type=${state.type}`
    } else if (state.latitude && state.longitude) {
      path += `?latitude=${state.latitude}&longitude=${state.longitude}`
      if (state.zoom) path += `&zoom=${state.zoom}`
    }

    return path
  }

}