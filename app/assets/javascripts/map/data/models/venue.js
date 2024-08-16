/* exported AtlasVenue */

/* global Record */

class AtlasVenue extends AtlasRecord {

  static LABEL = 'Venue'
  static LABELS = 'Venues'
  static KEY = 'venue'
  static KEYS = 'venues'

  constructor(attrs) {
    super(attrs)
  }

  getEventIds(layer) {
    return layer == AtlasEvent.LAYER.online ? [] : this.offlineEventIds
  }

}
