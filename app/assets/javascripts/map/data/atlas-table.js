/* exported AtlasRecord */

class AtlasTable {

  #atlas
  #model
  #cached = {}
  #loading = {}
  #requests = []
  #debug = true

  constructor(api, model) {
    this.#atlas = api
    this.#model = model
  }

  #request(query, args) {
    if (this.#debug) console.log('[Data] New Request:', query, args) // eslint-disable-line no-console

    const promise = this.#atlas[query](args)
    const request = new DataRequest(promise, args)
    if (args.id) request.ids = [args.id]
    return request
  }

  cache(records) {
    if (this.#debug) console.log('[Data]', 'Caching', records.length, this.#model.LABELS) // eslint-disable-line no-console
    
    return records.map(record => {
      this.#cached[record.id] = new this.#model(record)
      delete this.#loading[record.id]
      return this.#cached[record.id]
    })
  }

  fetch(id) {
    if (this.#debug) this.#logRequest('FETCH', [id])

    // Check if record is already cached
    if (id in this.#cached) {
      if (this.#debug) console.log('[Data]', 'Return Cached', this.#model.LABEL) // eslint-disable-line no-console
      return Promise.resolve(this.#cached[id])
    }

    // Check if record is already being loaded
    if (id in this.#loading) {
      if (this.#debug) console.log('[Data]', 'Return Pending', this.#model.LABEL) // eslint-disable-line no-console
      // And return the loading request if needed
      return this.#loading[id]
    }

    // Create a new request
    const request = this.#request(`fetch${this.#model.label}`, { id: id }).then(response => {
      const record = response[this.#model.KEY]
      return this.cache([record])[0]
    })

    this.#requests.push(request)
    return request
  }

  fetchAll(ids) {
    try {
      if (this.#debug) this.#logRequest('FETCH ALL', ids)
      // if (this.#debug) console.log('[Data]', 'FETCH ALL', this.#model.LABELS, ids.join(","), '\r\n\r\nState:', '\r\nCache', JSON.stringify(this.#cached), '\r\nPending', JSON.stringify(this.#loading)) // eslint-disable-line no-console
      let uncachedIds = ids.filter(id => !(id in this.#cached))
      
      // Check for cached records
      if (uncachedIds.length == 0) {
        if (this.#debug) console.log('[Data]', 'Return Cached', this.#model.LABELS) // eslint-disable-line no-console
        const records = ids.map(id => this.#cached[id])
        return Promise.resolve(records)
      }

      // Check for currently loading records
      uncachedIds = uncachedIds.filter(id => !(id in this.#loading))

      if (uncachedIds.length > 0) {
        // Start a new request for records, if needed
        const request = this.#request(`fetchAll${this.#model.LABELS}`, { ids: uncachedIds }).then(response => {
          try {
            // Cache the new records
            this.cache(response[this.#model.KEYS])

            // Remove this request from the pending request list
            this.#requests = this.#requests.filter(item => item !== request)
            if (this.#debug) console.log('[Data] State:', '\r\nCache', this.#cached, '\r\nPending', JSON.stringify(this.#loading)) // eslint-disable-line no-console
          } catch (err) { console.error(err) }
        })

        // Add this request to the pending request lists
        uncachedIds.forEach((id) => { this.#loading[id] = request })
        this.#requests.push(request)
      }

      // GATHER ALL OUTSTANDING REQUESTS
      const requests = this.#requests.filter(request => Util.hasIntersection(request.ids, ids))
      if (this.#debug) console.log('[Data]', this.#model.label, 'Waiting for', requests.length, 'requests', requests) // eslint-disable-line no-console
      return Promise.all(requests).then(() => {
        // Gather all requested events
        return ids.map(id => this.#cached[id])
      })
    } catch (err) { console.error(err) }
  }

  #logRequest(name, ids) {
    const total = ids.length
    const cachedCount = ids.filter(id => (id in this.#cached)).length
    const pendingCount = ids.filter(id => (id in this.#loading)).length
    const missCount = total - cachedCount - pendingCount
    let infoText = ''
    if (cachedCount > 0) infoText += '\r\nCached: ' + (cachedCount / total * 100).toFixed(0) + '%'
    if (pendingCount > 0) infoText += '\r\nPending: ' + (pendingCount / total * 100).toFixed(0) + '%'
    if (missCount > 0) infoText += '\r\nCache Miss: ' + (missCount / total * 100).toFixed(0) + '%'
    
    console.log('[Data]', name.toUpperCase(), this.#model.LABELS, ids.join(","), infoText) // eslint-disable-line no-console
  }

}