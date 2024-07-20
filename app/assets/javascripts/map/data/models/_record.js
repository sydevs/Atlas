/* exported AtlasRecord */

const ATLAS_DEBUG = true

class AtlasRecord {

  constructor(attrs) {
    Object.assign(this, attrs)

    if (this.parentType && this.parentId) {
      this[this.parentType.toLowerCase()] = {
        id: this.parentId
      }
    }
  }

}