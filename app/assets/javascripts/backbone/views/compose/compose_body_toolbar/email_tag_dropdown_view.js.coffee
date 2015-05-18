class TuringEmailApp.Views.EmailTagDropdownView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/compose/compose_body_toolbar/email_tag_dropdown"]

  events:
    "click .email-tag-item": "tagItem"

  initialize: (options) ->
    super(options)

    @composeView = options.composeView

  render: ->
    @$el.append(@template())

    @

  tagItem: (evt) ->
    @composeView.
      $(".tm_compose-body .redactor-editor").
      append("<meta name='email-type-tag' content='" +
             $(evt.target).text().toLowerCase() +
             "'>")
    TuringEmailApp.showAlert("Email tag successfully inserted!",
                             "alert-success",
                             3000)
