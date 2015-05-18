describe "InboxCleanerRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @inboxCleanerRouter = new TuringEmailApp.Routers.InboxCleanerRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@inboxCleanerRouter.routes["inbox_cleaner"]).toEqual "showInboxCleaner"

  describe "list_subscriptions", ->
    beforeEach ->
      @showInboxCleanerStub = sinon.stub(TuringEmailApp, "showInboxCleaner")
      @inboxCleanerRouter.navigate "inbox_cleaner", trigger: true

    afterEach ->
      @showInboxCleanerStub.restore()

    it "shows the list subscriptions", ->
      expect(@showInboxCleanerStub).toHaveBeenCalled()
