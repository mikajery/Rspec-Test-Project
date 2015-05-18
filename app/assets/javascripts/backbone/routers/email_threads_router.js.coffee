class TuringEmailApp.Routers.EmailThreadsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_thread/:emailThreadUID": "showEmailThread"
    "email_draft/:emailThreadUID": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    TuringEmailApp.currentEmailThreadIs(emailThreadUID)

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.showEmailEditorWithEmailThread(emailThreadUID)
