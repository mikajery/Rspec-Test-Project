describe "SettingsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @settingsRouter = new TuringEmailApp.Routers.SettingsRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@settingsRouter.routes["settings"]).toEqual "showSettings"

  describe "settings", ->
    beforeEach ->
      @showSettingsStub = sinon.stub(TuringEmailApp, "showSettings")
      @settingsRouter.navigate "settings", trigger: true

    afterEach ->
      @showSettingsStub.restore()

    it "shows the settings", ->
      expect(@showSettingsStub).toHaveBeenCalled()
