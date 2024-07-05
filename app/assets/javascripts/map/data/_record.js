/* exported AtlasRecord */

class AtlasRecord {

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

}