class TuringEmailApp.Routers.EmailTrackersRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_trackers": "showEmailTrackers"

  showEmailTrackers: ->
    TuringEmailApp.showEmailTrackers()
