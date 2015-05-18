describe "DelayedEmailsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @scheduleEmailsRouter = new TuringEmailApp.Routers.ScheduleEmailsRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@scheduleEmailsRouter.routes["schedule_emails"]).toEqual "showScheduleEmails"

  describe "schedule_emails", ->
    beforeEach ->
      @showScheduleEmailsStub = sinon.stub(TuringEmailApp, "showScheduleEmails")
      @scheduleEmailsRouter.navigate "schedule_emails", trigger: true

    afterEach ->
      @showScheduleEmailsStub.restore()

    it "shows the scheduled emails", ->
      expect(@showScheduleEmailsStub).toHaveBeenCalled()
