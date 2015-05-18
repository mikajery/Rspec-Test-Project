class TuringEmailApp.Routers.InfoRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "about": "showAbout"
    "faq": "showFAQ"
    "privacy": "showPrivacy"
    "terms": "showTerms"

  showAbout: ->
    TuringEmailApp.showAbout()

  showFAQ: ->
    TuringEmailApp.showFAQ()

  showPrivacy: ->
    TuringEmailApp.showPrivacy()

  showTerms: ->
    TuringEmailApp.showTerms()
