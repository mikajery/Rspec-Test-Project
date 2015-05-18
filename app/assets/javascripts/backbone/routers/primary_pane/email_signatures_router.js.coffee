class TuringEmailApp.Routers.EmailSignaturesRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_signatures": "showEmailSignatures"

  showEmailSignatures: ->
    TuringEmailApp.showEmailSignatures()
