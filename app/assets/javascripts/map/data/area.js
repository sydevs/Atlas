/* exported AtlasArea */

/* global Record */

class AtlasArea extends AtlasRecord {

  constructor(attrs) {
    super(attrs)
  }

  getEventIds(layer) {
    return layer == AtlasEvent.LAYER.online ? this.onlineEventIds : this.offlineEventIds
  }

}
