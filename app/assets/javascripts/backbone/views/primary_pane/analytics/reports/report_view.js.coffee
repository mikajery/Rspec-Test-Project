TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView extends TuringEmailApp.Views.BaseView
  initialize: (options) ->
    super(options)

    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)
