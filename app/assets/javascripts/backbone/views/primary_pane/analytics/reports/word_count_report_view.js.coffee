TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.WordCountReportView extends  TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/word_count_report"]

  className: "report-view"

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html(@template(googleChartData))

    @

  getGoogleChartData: ->
    data =
      wordCountsGChartData: [["Count", "Received", "Sent"]].concat(
        @model.get("word_counts")
      )

    return data
