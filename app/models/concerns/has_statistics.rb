module HasStatistics

  extend ActiveSupport::Concern

  COLORS = [
    '#92BBB8', #'rgb(255, 99, 132)',
    '#E08E79', #'rgb(255, 159, 64)',
    '#A06CD5', #'rgb(255, 205, 86)',
    '#F7CE5B', #'rgb(75, 192, 192)',
    '#7AC670', #'rgb(54, 162, 235)',
  ]

  def registrations_chart_url
    recent_month_names = 6.downto(1).collect do |n| 
      Date.parse(Date::MONTHNAMES[n.months.ago.month]).strftime('%b')
    end

    online_registrations = registrations.online.since(6.months.ago).group_by_month.count.map { |k, v| [k.strftime("%b"), v] }.to_h
    offline_registrations = registrations.offline.since(6.months.ago).group_by_month.count.map { |k, v| [k.strftime("%b"), v] }.to_h

    chart_url({
      "type": "bar",
      "data": {
        "labels": recent_month_names,
        "datasets": [
          {
            "label": "online",
            "data": recent_month_names.map { |m| online_registrations[m] || 0 },
            "backgroundColor": COLORS[0],
            "borderWidth": 0
          },
          {
            "label": "offline",
            "data": recent_month_names.map { |m| offline_registrations[m] || 0 },
            "backgroundColor": COLORS[1],
            "borderWidth": 0
          },
        ]
      },
      "options": {
        "rectangleRadius": 10,
        "elements": {
          "point": {
            "radius": 25,
            "hoverRadius": 35,
            "pointStyle": "rectRounded"
          }
        },
        "cornerRadius": 10,
        "fullCornerRadius": false,
        "scales": {
          "yAxes": [
            {
              "ticks": {
                "beginAtZero": true
              },
              "stacked": true,
              "radius": 25
            }
          ],
          "xAxes": [
            {
              "ticks": {
                "beginAtZero": true
              },
              "stacked": true
            }
          ]
        }
      }
    })
  end

  def regions_chart_url
    registrations = Registration.since(1.month.ago).reorder(nil).joins(:area).group('areas.name').count

    chart_url({
      type: 'doughnut',
      data: {
        datasets: [
          {
            data: registrations.values,
            backgroundColor: COLORS,
            label: 'Registrations by Area',
          },
        ],
        labels: registrations.keys,
      },
    })
  end

  private

    def chart_url config
      config = CGI.escape(config.to_json)
      "https://image-charts.com/chart.js/2.8.0?bkg=white&chart=#{config}"
    end

end
