/* exported AtlasEvent */

/* global Record */

class AtlasEvent extends AtlasRecord {

  static LAYER = {
    offline: 'f',
    online: 'n',
  }

  constructor(attrs) {
    super(attrs)
    this.timing = new EventTiming(attrs)
    this.layer = attrs.online ? AtlasEvent.LAYER.online : AtlasEvent.LAYER.offline
    this.location = AtlasApp.data.parse(this.location)
  }

  get offline() {
    return !this.online
  }

  get order() {
    let order = this.distanceTo(AtlasApp.map.sortLocation)
    if (AtlasApp.config.locale != this.languageCode) order *= 1.2
    if (this.timing.startingSoon) order *= 0.5
    return order
  }

  distanceTo(location) {
    let distance = Util.distance(this.location.latitude, this.location.longitude, location.latitude, location.longitude)
    return Math.round(distance * 10) / 10
  }

}
