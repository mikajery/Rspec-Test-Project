class TuringEmailApp.Routers.AnalyticsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "analytics": "showAnalytics"

  showAnalytics: ->
    TuringEmailApp.showAnalytics()
