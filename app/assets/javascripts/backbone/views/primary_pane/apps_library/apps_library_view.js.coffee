TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.AppsLibrary ||= {}

class TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/apps_library/apps_library"]
  className: "tm_content tm_apps-view"


  events: -> _.extend {}, super(),
    "click .create-app-button": "onCreateAppButtonClick"
    "click .install-app-button": "onInstallAppButtonClick"


  data: -> _.extend {}, super(),
    "static":
      "developer_enabled": @developer_enabled
    "dynamic":
      "apps": @collection


  initialize: (options) ->
    super(options)
    @developer_enabled = options.developer_enabled


  render: ->
    super()

    @setupButtons()

    @


  setupButtons: ->
    @createAppView =
      new TuringEmailApp.Views.PrimaryPane.AppsLibrary.CreateAppView
        "el": @$(".create_app_view")
    @listenTo @createAppView.model, "sync", -> @collection.fetch()
    @createAppView.render()


  onCreateAppButtonClick: ->
    @createAppView.show()


  onInstallAppButtonClick: (evt) ->
    index = @$(".install-app-button").index(evt.currentTarget)
    app = @collection.at(index)

    @trigger("installAppClicked", this, app.get("uid"))

    TuringEmailApp.showAlert("You have installed the app!", "alert-success", 3000)
