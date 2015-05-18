class TuringEmailApp.Routers.TourRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "welcome_tour": "showWelcomeTour"

  showWelcomeTour: ->
    TuringEmailApp.showWelcomeTour()
