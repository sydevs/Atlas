/* global $, Chartist */
/* exported Chart */

const Chart = {
  load() {
    console.log('Loading Chart') // eslint-disable-line no-console

    this.$chart = $('#chart')
    this.chart = new Chartist.Line('#chart', this.$chart.data('plot'), {
      fullWidth: true,
      axisY: {
        onlyInteger: true,
      },
    })
  },
}

$(document).on('ready', function() {
  if ($('#chart').length > 0) {
    Chart.load()
  }
})
