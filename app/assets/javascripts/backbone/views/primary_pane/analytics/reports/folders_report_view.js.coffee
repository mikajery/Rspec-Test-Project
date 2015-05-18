TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.FoldersReportView extends  TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/folders_report"]

  className: "report-view"

  render: ->
    chartData = @getChartData()

    @$el.html @template()

    @drawChart chartData, ".email-folders-chart", "Email Folders Share"

    @

  getChartData: ->
    data = [
      [ 'Drafts Folder', @model.get("percent_draft") ]
      [ 'Inbox Folder', @model.get("percent_inbox") ]
      [ 'Sent Folder', @model.get("percent_sent") ]
      [ 'Spam Folder', @model.get("percent_spam") ]
      [ 'Starred Folder', @model.get("percent_starred") ]
      [ 'Trash Folder', @model.get("percent_trash") ]
      # [ 'Unread Folder', @model.get("percent_unread") ]
    ]

    return data

  drawChart: (chartData, divSelector, chartTitle) ->
    return if $(divSelector).length is 0

    @$el.find(divSelector).highcharts
      chart:
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
        style: fontFamily: "'Gotham SSm A', 'Gotham SSm B', 'Helvetica Neue', Helvetica, Arial, sans-serif", fontSize: "12px", fontWeight: "300"
      title: text: chartTitle
      credits: enabled: false
      tooltip:
        shadow: false
        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
      plotOptions: pie:
        allowPointSelect: true
        cursor: 'pointer'
        dataLabels:
          enabled: true
          format: '<b>{point.name}</b>: {point.percentage:.1f} %'
          style: color: Highcharts.theme and Highcharts.theme.contrastTextColor or 'black'
        showInLegend: true
      series: [{
        type: 'pie'
        name: 'Share'
        data: chartData
      }]
      legend:
        align: 'right'
        layout: 'vertical'
        verticalAlign: 'middle'
