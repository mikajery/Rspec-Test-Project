class TuringEmailApp.Views.AlertView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/alert/alert"]

  events:
    "click .tm_alert-dismiss": "removeAlert"

  initialize: (options) ->
    super(options)

    @text = options.text
    @classType = options.classType
    @setElement(@template({'text': @text}))
    @token = _.uniqueId()

  render: ->
    @$el.addClass(@classType)

    @

  removeAlert: ->
    TuringEmailApp.removeAlert @token
