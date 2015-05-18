describe "EmailThreadsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@emailThreadsRouter.routes["email_thread/:emailThreadUID"]).toEqual "showEmailThread"
    expect(@emailThreadsRouter.routes["email_draft/:emailThreadUID"]).toEqual "showEmailDraft"

  describe "email_thread/:emailThreadUID", ->
    beforeEach ->
      @emailThreadUID = "12345"
      
      @spy = sinon.spy(TuringEmailApp, "currentEmailThreadIs")
      @emailThreadsRouter.navigate "email_thread/" + @emailThreadUID, trigger: true

    afterEach ->
      @spy.restore()

    it "shows the email thread", ->
      expect(@spy).toHaveBeenCalledWith(@emailThreadUID)

  describe "email_draft/:emailThreadUID", ->
    beforeEach ->
      @emailThreadUID = "12345"

      @spy = sinon.spy(TuringEmailApp, "showEmailEditorWithEmailThread")
      @emailThreadsRouter.navigate "email_draft/" + @emailThreadUID, trigger: true

    afterEach ->
      @spy.restore()

    it "shows the email editor with the email thread", ->
      expect(@spy).toHaveBeenCalledWith(@emailThreadUID)
