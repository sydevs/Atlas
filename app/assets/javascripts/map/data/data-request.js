/* exported DataCache */

/* global AtlasAPI, Util */

class DataRequest {

  resolved
  #promise

  constructor(promise, args = {}) {
    Object.assign(this, args)
    this.resolved = false
    this.#promise = promise.catch(err => console.error(err)).finally(() => { this.resolved = true })
  }

  then(...args) {
    this.#promise = this.#promise.then(...args)
    return this
  }

  catch(...args) {
    this.#promise = this.#promise.catch(...args)
    return this
  }

  finally(...args) {
    this.#promise = this.#promise.finally(...args)
    return this
  }

  static resolve(...args) {
    return new DataRequest(Promise.resolve(...args))
  }

  static all(promises) {
    promises = promises.map(promise => promise instanceof DataRequest ? promise.#promise : promise)
    
    return new DataRequest(Promise.all(promises))
  }

}
