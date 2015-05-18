TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.GeoReportView extends  TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/geo_report"]

  className: "report-view"

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html @template()

    @renderGoogleChart googleChartData

    @

  getGoogleChartData: ->
    ipStats = @model.get("ip_stats")

    cityStats = {}

    for ipStat in ipStats
      cityStats[ipStat.ip_info.city] ?= 0
      cityStats[ipStat.ip_info.city] += ipStat.num_emails

    data =
      cityStats: [["City", "Number of Emails"]].concat(
        _.zip(_.keys(cityStats), _.values(cityStats))
      )

    return data

  renderGoogleChart: (googleChartData) ->
    google.load('visualization', '1.0',
                 callback: => @drawGeoChart(googleChartData, ".geo-chart")
                 packages: ["corechart"])

  drawGeoChart: (googleChartData, divSelector) ->
    return if $(divSelector).length is 0

    options =
      region: "US"
      displayMode: "markers"

    chart = new google.visualization.GeoChart($(divSelector)[0])
    dataTable = google.visualization.arrayToDataTable(googleChartData.cityStats)
    chart.draw dataTable, options
