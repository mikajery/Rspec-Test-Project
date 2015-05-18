TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.AppsLibrary ||= {}

class TuringEmailApp.Views.PrimaryPane.AppsLibrary.CreateAppView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/apps_library/create_app"]


  events: -> _.extend {}, super(),
    "submit .create-app-form": "onSubmit"


  data: -> _.extend {}, super(),
    "dynamic":
      "app": @model


  initialize: (options) ->
    super(options)
    @model = new TuringEmailApp.Models.App
    @model.urlRoot = TuringEmailApp.Collections.AppsCollection.prototype.url


  show: ->
    @$(".dropdown a").trigger("click.bs.dropdown")


  hide: ->
    @$(".dropdown a").trigger("click.bs.dropdown")


  onSubmit: ->
    @model.save {}, "success": =>
      TuringEmailApp.showAlert("You have successfully created the app!",
                               "alert-success",
                               3000)
      @model.clear()

    @hide()
