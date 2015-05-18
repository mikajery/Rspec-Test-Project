describe "TourRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @tourRouter = new TuringEmailApp.Routers.TourRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@tourRouter.routes["welcome_tour"]).toEqual "showWelcomeTour"

  describe "welcome tour", ->
    beforeEach ->
      @showWelcomeTourStub = sinon.stub(TuringEmailApp, "showWelcomeTour")
      @tourRouter.navigate "welcome_tour", trigger: true

    afterEach ->
      @showWelcomeTourStub.restore()

    it "shows the welcome tour", ->
      expect(@showWelcomeTourStub).toHaveBeenCalled()
