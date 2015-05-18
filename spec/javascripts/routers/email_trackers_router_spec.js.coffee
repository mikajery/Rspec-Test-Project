describe "EmailTrackersRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailTrackersRouter = new TuringEmailApp.Routers.EmailTrackersRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@emailTrackersRouter.routes["email_trackers"]).toEqual "showEmailTrackers"

  describe "email_trackers", ->
    beforeEach ->
      @showEmailTrackersStub = sinon.stub(TuringEmailApp, "showEmailTrackers")
      @emailTrackersRouter.navigate "email_trackers", trigger: true

    afterEach ->
      @showEmailTrackersStub.restore()

    it "shows the email trackers", ->
      expect(@showEmailTrackersStub).toHaveBeenCalled()
