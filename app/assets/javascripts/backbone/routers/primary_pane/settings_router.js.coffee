class TuringEmailApp.Routers.SettingsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "settings": "showSettings"

  showSettings: ->
    TuringEmailApp.showSettings()
