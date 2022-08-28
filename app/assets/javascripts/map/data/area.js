/* exported AtlasArea */

/* global Record */

class AtlasArea extends AtlasRecord {

  constructor(attrs) {
    attrs.eventIds = attrs.onlineEventIds
    super(attrs)
  }

}