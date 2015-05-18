describe "SearchResultsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@searchResultsRouter.routes["search/:query"]).toEqual "showSearchResults"

  describe "search/:query", ->
    beforeEach ->
      @stub = sinon.stub(TuringEmailApp, "loadSearchResults", ->)
      @query = "test search"
      
      @searchResultsRouter.navigate "search/" + @query, trigger: true

    afterEach ->
      @stub.restore()

    it "loads the search results", ->
      expect(@stub).toHaveBeenCalledWith(@query)
