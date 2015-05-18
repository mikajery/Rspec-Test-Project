TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.QuickReplyView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/email_threads/quick_reply_dropdown"]

  initialize: (options) ->
    super(options)

    @emailThreadView = options.emailThreadView

  render: ->
    @$el.after(@template())

    @$el.parent().find(".quick-reply-option").click (evt) =>
      evt.preventDefault()
      @emailThreadView.trigger("replyClicked", @emailThreadView)
      $(".tm_compose-body .redactor-editor").prepend($(evt.target).text() + "<br /><br /> - Sent with Turing Quick Response.")
      $(".compose-modal .send-button").click()

    @
