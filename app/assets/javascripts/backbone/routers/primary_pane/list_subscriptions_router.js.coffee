class TuringEmailApp.Routers.ListSubscriptionsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "list_subscriptions": "showListSubscriptions"

  showListSubscriptions: ->
    TuringEmailApp.showListSubscriptions()
