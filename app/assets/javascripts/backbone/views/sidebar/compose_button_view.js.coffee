class TuringEmailApp.Views.ComposeButtonView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/sidebar/compose_button"]

  events:
    "click .quick-compose-item": "quickCompose"

  render: ->
    @$el.prepend(@template())

    @

  quickCompose: (evt) ->
    @$(".tm_compose-button").click()
    quickComposeText = $(evt.target).text()
    $(".tm_compose-body .redactor-editor").prepend(quickComposeText)
    $(".compose-modal .subject-input").val(quickComposeText)
    $(".compose-modal .to-input").focus()
