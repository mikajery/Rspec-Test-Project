TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.InboxCleanerView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/inbox_cleaner"]

  className: "tm_content tm_inbox-cleaner-view"

  events:
    "click .auto-file-button": "autoFile"

  initialize: (options) ->
    super(options)

    @app = options.app

    if @model
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.empty()

    @$el.html(@template(@model.toJSON())) if _.keys(@model.attributes).length > 0

    @

  autoFile: (evt) ->
    $(evt.currentTarget).prop("disabled", true)
    @app.showAlert("The emails are being filed away!", "alert-success", 5000)

    TuringEmailApp.Models.CleanerReport.Apply().done(
      => @model.fetch()
    )
