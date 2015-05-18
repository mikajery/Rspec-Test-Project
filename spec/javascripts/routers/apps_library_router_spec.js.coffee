describe "AppsLibraryRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @appsLibraryRouter = new TuringEmailApp.Routers.AppsLibraryRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@appsLibraryRouter.routes["apps"]).toEqual "showAppsLibrary"

  describe "apps", ->
    beforeEach ->
      @showAppsLibraryStub = sinon.stub(TuringEmailApp, "showAppsLibrary")
      @appsLibraryRouter.navigate "apps", trigger: true

    afterEach ->
      @showAppsLibraryStub.restore()

    it "shows the apps library", ->
      expect(@showAppsLibraryStub).toHaveBeenCalled()
