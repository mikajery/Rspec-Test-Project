class TuringEmailApp.Routers.InboxCleanerRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "inbox_cleaner": "showInboxCleaner"

  showInboxCleaner: ->
    TuringEmailApp.showInboxCleaner()
