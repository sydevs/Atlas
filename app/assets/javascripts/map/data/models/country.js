/* exported AtlasCountry */

/* global Record */

class AtlasCountry extends AtlasRecord {

  static LABEL = 'Country'
  static LABELS = 'Countries'
  static KEY = 'country'
  static KEYS = 'countries'

  constructor(attrs) {
    super(attrs)
  }

}
