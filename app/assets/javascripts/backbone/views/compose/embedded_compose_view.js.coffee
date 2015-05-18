class TuringEmailApp.Views.EmbeddedComposeView extends TuringEmailApp.Views.ComposeView
  template: JST["backbone/templates/compose/_compose_form"]

  initialize: (options) ->
    super(options)

  render: ->
    super()

    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(@email)

    @

  hide: ->
    @$("#compose-form").hide()
