/* exported AtlasEvent */

/* global Record */

class AtlasEvent extends AtlasRecord {

  static LAYER = {
    offline: 'off',
    online: 'on',
  }

  constructor(attrs) {
    super(attrs)
    this.timing = new EventTiming(attrs)
    this.layer = attrs.online ? AtlasEvent.LAYER.online : AtlasEvent.LAYER.offline
  }

  get offline() {
    return !this.online
  }

  get order() {
    let order = this.distance
    if (window.locale != this.languageCode) order *= 1.2
    if (this.timing.startingSoon) order *= 0.5
    return this.distanceTo(App.map.sortLocation)
  }

  distanceTo(location) {
    let distance = Util.distance(this.location.latitude, this.location.longitude, location.latitude, location.longitude)
    return Math.round(distance * 10) / 10
  }

}
