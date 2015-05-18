class TuringEmailApp.Routers.SearchResultsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "search/:query": "showSearchResults"

  showSearchResults: (query) ->
    TuringEmailApp.loadSearchResults(query)
