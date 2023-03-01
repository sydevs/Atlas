/* exported AtlasVenue */

/* global Record */

class AtlasVenue extends AtlasRecord {

  constructor(attrs) {
    super(attrs)
  }

  getEventIds(layer) {
    return layer == AtlasEvent.LAYER.online ? [] : this.offlineEventIds
  }

}
