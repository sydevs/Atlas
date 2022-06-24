
class AtlasEvent extends Record {

  constructor(attrs) {
    super(attrs)
  }

  get order() {
    let order = this.distance
    if (window.locale != this.languageCode) order += 5
    return this.distanceTo(App.map.sortLocation)
  }

  distanceTo(location) {
    this.distance = Util.distance(this.location, location)
  }

}
