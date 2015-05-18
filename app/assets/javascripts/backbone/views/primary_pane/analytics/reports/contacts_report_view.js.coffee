TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ContactsReportView extends TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/contacts_report"]

  className: "report-view"

  render: ->
    chartData = @getChartData()

    @$el.html @template()

    @drawCharts chartData

    @

  getChartData: ->
    topSenders = @model.get("top_senders")
    topRecipients = @model.get("top_recipients")

    data =
      topSenders: _.zip(_.keys(topSenders), _.values(topSenders))
      topRecipients: _.zip(_.keys(topRecipients), _.values(topRecipients))

    return data

  drawCharts: (chartData) ->
    @drawChart chartData.topSenders, ".incoming-emails-container", "Incoming Emails"
    @drawChart chartData.topRecipients, ".outgoing-emails-container", "Outgoing Emails"

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
        dataLabels: enabled: false
        showInLegend: true
      series: [{
        type: 'pie'
        name: 'Senders'
        data: chartData
      }]
      legend:
        align: 'center'
        layout: 'vertical'
        verticalAlign: 'bottom'
