class TuringEmailApp.Routers.AppsLibraryRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "apps": "showAppsLibrary"

  showAppsLibrary: ->
    TuringEmailApp.showAppsLibrary()
