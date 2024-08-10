/* global $, Chartist */
/* exported Statistics */

const Statistics = {
  load: function() {
    this.$chart = $('#chart-world-registrations')
    let data = this.$chart.data('registrations')
    console.log(data, data.series.length, Array.apply(null, Array(data.series.length - 1)) + ['ct-series-world'])
    this.chart = new Chartist.Line('#chart-world-registrations', data, {
      fullWidth: true,
      low: 0,
      axisY: {
        onlyInteger: true,
      },
      series: {
        'World': {
          showArea: true,
        }
      },
      plugins: [Chartist.plugins.legend({
        classNames: Array.from(data.series).map((s) => s.name == 'World' ? 'ct-series-world' : '')
      })]
    })

    this.$pie = $('#chart-country-registrations')
    let pieData = this.$pie.data('registrations')
    this.pie = new Chartist.Pie('#chart-country-registrations', pieData, {
      fullWidth: true,
      chartPadding: 30,
      showLabel: false,
      labelOffset: 100,
      labelDirection: 'explode',
      plugins: [Chartist.plugins.legend()]
    })

    this.$map = $('#map-world-events')
    data = this.$map.data('events')

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
          el.html(el.html() + ' (' + data[code] + ' Events)')
        }
      }
    })
  },
}

$(document).on('ready', function() { Statistics.load() })
