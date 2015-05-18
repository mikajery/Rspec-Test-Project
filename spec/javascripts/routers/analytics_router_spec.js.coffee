describe "AnalyticsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@analyticsRouter.routes["analytics"]).toEqual "showAnalytics"

  describe "analytics", ->
    beforeEach ->
      @showAnalyticsSpy = sinon.spy(TuringEmailApp, "showAnalytics")
      @analyticsRouter.navigate "analytics", trigger: true

    afterEach ->
      @showAnalyticsSpy.restore()

    it "shows the analytics", ->
      expect(@showAnalyticsSpy).toHaveBeenCalled()
