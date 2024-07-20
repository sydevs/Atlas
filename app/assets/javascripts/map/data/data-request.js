/* exported DataCache */

/* global AtlasAPI, Util */

class DataRequest {

  resolved
  #promise

  constructor(promise, args) {
    Object.assign(this, args)
    this.resolved = false
    this.#promise = promise.catch(err => console.error(err)).finally(() => { this.resolved = true })
  }

  then(...args) {
    this.#promise = this.#promise.then(...args)
    return this
  }

}
