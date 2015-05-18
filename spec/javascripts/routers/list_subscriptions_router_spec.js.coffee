describe "ListSubscriptionsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @listSubscriptionsRouter = new TuringEmailApp.Routers.ListSubscriptionsRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@listSubscriptionsRouter.routes["list_subscriptions"]).toEqual "showListSubscriptions"

  describe "list_subscriptions", ->
    beforeEach ->
      @showListSubscriptionsStub = sinon.stub(TuringEmailApp, "showListSubscriptions")
      @listSubscriptionsRouter.navigate "list_subscriptions", trigger: true

    afterEach ->
      @showListSubscriptionsStub.restore()

    it "shows the list subscriptions", ->
      expect(@showListSubscriptionsStub).toHaveBeenCalled()
