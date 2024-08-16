/* exported AtlasArea */

/* global Record */

class AtlasArea extends AtlasRecord {

  static LABEL = 'Area'
  static LABELS = 'Areas'
  static KEY = 'area'
  static KEYS = 'areas'

  constructor(attrs) {
    super(attrs)
  }

  getEventIds(layer) {
    return layer == AtlasEvent.LAYER.online ? this.onlineEventIds : this.offlineEventIds
  }

}
