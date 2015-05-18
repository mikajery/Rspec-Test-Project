TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.AttachmentsReportView extends TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/attachments_report"]

  className: "report-view"

  render: ->
    chartData = @getChartData()

    @$el.html @template()

    @drawChart chartData

    @

  getChartData: ->
    contentTypeStats = @model.get("content_type_stats")
    reducedContentTypeStats = @getReducedContentTypeStats(contentTypeStats)

    data =
      averageFileSize: @model.get("average_file_size")
      categories: _.keys(reducedContentTypeStats)
      numAttachmentsData: _.pluck(reducedContentTypeStats, "numAttachments")
      averageFileSizeData: _.pluck(reducedContentTypeStats, "averageFileSize")

    return data

  addContentTypeStatsToRunningAverage: (stats, runningAverages, runningAverageKey) ->
    runningAverages[runningAverageKey] ?= {}
    runningAverage = runningAverages[runningAverageKey]

    runningAverage.numAttachments ?= 0
    runningAverage.averageFileSize ?= 0

    runningAverage.averageFileSize = (runningAverage.averageFileSize * runningAverage.numAttachments +
                                      stats.average_file_size * stats.num_attachments) /
                                      (stats.num_attachments + runningAverage.numAttachments)
    runningAverage.numAttachments += stats.num_attachments

  getReducedContentTypeStats: (contentTypeStats) ->
    contentTypeReductionMap =
      "ics": "Calendar Invite"
      "zip": "Zip"
      "pdf": "PDF"
      "msword": "Document"
      "vnd.openxmlformats-officedocument.wordprocessingml.document": "Document"
      "vnd.openxmlformats-officedocument.presentationml.presentation": "Presentation"
      "vnd.openxmlformats-officedocument.spreadsheetml.sheet": "Spreadsheet"

    reducedContentTypeStats = {}

    for contentType, stats of contentTypeStats
      contentTypeParts = contentType.split("/")
      type = contentTypeParts[0].toLowerCase()
      subtype = contentTypeParts[1].toLowerCase()

      reducedType = if type is "image" then "Image" else (contentTypeReductionMap[subtype] ? "Other")
      @addContentTypeStatsToRunningAverage(stats, reducedContentTypeStats, reducedType)

    return reducedContentTypeStats

  drawChart: (chartData) ->
    @$el.find('.attachments-chart').highcharts
      chart:
        type: 'column'
        style: fontFamily: "'Gotham SSm A', 'Gotham SSm B', 'Helvetica Neue', Helvetica, Arial, sans-serif", fontSize: "12px", fontWeight: "300"
      title: text: 'Number of Attachments and Average File Size'
      credits: enabled: false
      tooltip:
        shadow: false
      plotOptions: bar: dataLabels: enabled: true
      xAxis:
        categories: chartData.categories
        title: text: null
      yAxis: [{
        min: 0
        title: text: null
      }, {
        min: 0
        opposite: true
        title: text: null
        labels: formatter: ->
          bytes = @value
          thresh = 1000
          if bytes < thresh
            return bytes + ' B'
          units = ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
          u = -1
          loop
            bytes /= thresh
            ++u
            unless bytes >= thresh
              break
          bytes.toFixed(1) + ' ' + units[u]
      }]
      series: [{
        yAxis: 0
        showInLegend: false
        name: 'Attachments'
        data: chartData.numAttachmentsData
      }, {
        yAxis: 1
        showInLegend: false
        name: 'Avg. File Size'
        data: chartData.averageFileSizeData
        tooltip:
          valueDecimals: 1
          valueSuffix: ' bytes'
      }]
