/* exported AtlasRecord */

const ATLAS_DEBUG = true

class AtlasRecord {

  static #cached = {}
  static #loading = {}
  static #requests = []

  static get label() {
    return this.name.slice(5)
  }

  static get key() {
    return this.label.toLowerCase()
  }

  constructor(attrs) {
    Object.assign(this, attrs)

    if (this.parentType && this.parentId) {
      this[this.parentType.toLowerCase()] = {
        id: this.parentId
      }
    }
  }

  static fetch(api, id) {
    if (ATLAS_DEBUG) console.log('[Data]', 'FETCH', this.label, id) // eslint-disable-line no-console

    // Check if record is already cached
    if (id in this.#cached) {
      return Promise.resolve(this.#cached[id])
    }

    // Check if record is already being loaded
    if (id in this.#loading) {
      // And return the loading request if needed
      return this.#loading[id]
    }

    // Create a new request
    const request = new DataRequest(api[`fetch${this.label}`], { id: id }).then(record => {
      if (ATLAS_DEBUG) console.log('[Data]', 'Caching', this.label, id) // eslint-disable-line no-console
      this.#cached[record.id] = new this(record)
    })

    this.#loading[id] = request
    this.#requests.append(request)
    return request
  }

  static fetchAll(api, ids) {
    console.log('tester:', AtlasEvent.#cached)
    if (ATLAS_DEBUG) console.log('[Data]', 'FETCH ALL', this.label, ids.join(",")) // eslint-disable-line no-console
    console.log('test', ids)
    const uncachedIds = ids.filter(id => !(id in this.#cached))
    console.log('test0', ids, this.#cached)
    
    // Check for cached records
    if (uncachedIds.length == 0) {
      if (ATLAS_DEBUG) console.log('[Data]', this.label, '100% cached') // eslint-disable-line no-console
      const records = ids.map(id => this.#cached[id])
      return Promise.resolve(records)
    }

    if (ATLAS_DEBUG) console.log('[Data]', this.label, (1 - uncachedIds.length / ids.length) * 100, '% cached') // eslint-disable-line no-console
    console.log('test1')

    // Check for currently loading records
    uncachedIds = uncachedIds.filter(id => !(id in this.#loading))

    console.log('test2')
    // Start a new request if needed
    if (uncachedIds.length > 0) {
      if (ATLAS_DEBUG) console.log('[Data]', this, (uncachedIds.length / ids.length) * 100, '% fresh requests') // eslint-disable-line no-console
      const request = new DataRequest(api[`fetchAll${this.label}`], { ids: uncachedIds }).then(response => {
        response[this.key].forEach(record => {
          if (ATLAS_DEBUG) console.log('[Data]', 'Caching', this, record.id) // eslint-disable-line no-console
          this.#cached[record.id] = new this(record)
          delete this.#loading[record.id]
        })

        this.#requests = this.#requests.filter(item => item !== request)
      })

      uncachedIds.forEach((id) => this.#loading[id] = request)
      this.#requests.append(request)
    }

    // GATHER ALL OUTSTANDING REQUESTS
    requests = this.#requests.filter(request => Util.hasIntersection(request.ids, ids))
    return Promise.all(requests)
  }

}