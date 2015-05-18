class TuringEmailApp.Views.BaseView extends Backbone.View
  events: ->
    "click a[data-prevent-default]": "preventDefault"
    "click button[data-prevent-default]": "preventDefault"
    "submit form": "preventDefault"


  initialize: (options) ->
    super(options)

    TuringEmailApp._observedViews ||= []
    TuringEmailApp._observedViews.push @


  preventDefault: (evt) ->
    evt.preventDefault()


  insertPartial: (partialPath, options = {}) ->
    parts = partialPath.split "/"
    name  = parts.pop()
    name  = "_#{name}" unless name[0] == "_"

    parts.push name
    parts.shift() if parts[0] == "backbone"
    parts.shift() if parts[0] == "templates"

    JST["backbone/templates/" + parts.join("/")](options)
