class TuringEmailApp.Models.App extends Backbone.Model
  idAttribute: "uid"

  defaults:
    "app_type": "panel"

  @Install: (appID) ->
    $.post "/api/v1/apps/install/" + appID
