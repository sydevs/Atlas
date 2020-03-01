/* global $, Chartist */
/* exported Statistics */

const Statistics = {
  load: function() {
    this.$chart = $('#chart-world-registrations')
    this.chart = new Chartist.Line('#chart-world-registrations', this.$chart.data('registrations'), {
      fullWidth: true,
      axisY: {
        onlyInteger: true,
      },
    })

    this.$map = $('#map-world-events')
    const data = this.$map.data('events')

    this.$map.vectorMap({
      map: 'world_mill',
      backgroundColor: 'white',
      zoomOnScroll: false,
      regionStyle: {
        initial: {
          'fill': 'lightgrey',
          'fill-opacity': 1,
          'stroke': 'none',
          'stroke-width': 0,
          'stroke-opacity': 1,
        },
        hover: {
          'fill-opacity': 0.8,
          'cursor': 'pointer',
        },
      },
      regionLabelStyle: {
        initial: {
          'font-family': '"Montserrat", sans-serif',
          'font-size': '12',
          'font-weight': 'bold',
          'fill': 'black',
        }
      },
      series: {
        regions: [{
          values: data,
          scale: ['#6b818f', '#0071A4'],
          normalizeFunction: 'polynomial'
        }]
      },
      onRegionTipShow: function(e, el, code) {
        if (typeof data[code] !== 'undefined') {
          el.html(el.html() + ' (' + data[code] + ' Active Events)')
        }
      }
    })
  },
}

$(document).on('ready', function() { Statistics.load() })
