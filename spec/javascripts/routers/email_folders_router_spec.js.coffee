describe "EmailFoldersRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@emailFoldersRouter.routes["email_folder/:emailFolderID"]).toEqual "showFolder"
    expect(@emailFoldersRouter.routes["email_folder/:emailFolderID/:pageTokenIndex"]).toEqual "showFolderPage"
    expect(@emailFoldersRouter.routes["email_folder/:emailFolderID/:pageTokenIndex/:lastEmailThreadUID/:dir"]).toEqual "showFolderPageDir"

  describe "email_folder/:emailFolderID", ->
    beforeEach ->
      @emailFolderID = "test"
      
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate("email_folder/" + @emailFolderID, trigger: true)

    afterEach ->
      @spy.restore()

    it "shows the folder", ->
      expect(@spy).toHaveBeenCalledWith(@emailFolderID)

  describe "email_folder/:emailFolderID/:pageTokenIndex", ->
    beforeEach ->
      @emailFolderID = "test"
      @pageTokenIndex = "1"
  
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate("email_folder/" + @emailFolderID + "/" + @pageTokenIndex, trigger: true)
  
    afterEach ->
      @spy.restore()
  
    it "shows the folder", ->
      expect(@spy).toHaveBeenCalledWith(@emailFolderID, @pageTokenIndex)

  describe "email_folder/:emailFolderID/:pageTokenIndex/:lastEmailThreadUID/:dir", ->
    beforeEach ->
      @emailFolderID = "test"
      @pageTokenIndex = "1"
      @lastEmailThreadUID = "2"
      @dir = "DESC"

      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @url = "email_folder/" + @emailFolderID + "/" + @pageTokenIndex + "/" + @lastEmailThreadUID + "/" + @dir
      @emailFoldersRouter.navigate(@url, trigger: true)

    afterEach ->
      @spy.restore()

    it "shows the folder", ->
      expect(@spy).toHaveBeenCalledWith(@emailFolderID, @pageTokenIndex, @lastEmailThreadUID, @dir)
