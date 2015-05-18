describe "App", ->
  describe "#Install", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

      @appID = "1"
      TuringEmailApp.Models.App.Install(@appID)

    afterEach ->
      @server.restore()

    it "posts the install request", ->
      expect(@server.requests.length).toEqual 1

      request = @server.requests[0]
      expect(request.method).toEqual("POST")
      expect(request.url).toEqual("/api/v1/apps/install/" + @appID)
      expect(request.requestBody).toEqual(null)

  beforeEach ->
    @app = new TuringEmailApp.Models.App(FactoryGirl.create("App"))
  
  it "uses uid as idAttribute", ->
    expect(@app.idAttribute).toEqual("uid")
